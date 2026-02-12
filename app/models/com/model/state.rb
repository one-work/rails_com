module Com
  module Model::State
    extend ActiveSupport::Concern

    included do
      if connection.adapter_name == 'PostgreSQL'
        attribute :id, :uuid
        attribute :parent_id, :uuid
      else
        attribute :id, :string, default: -> { SecureRandom.uuid_v7 }
        attribute :parent_id, :string
      end
      attribute :host, :string
      attribute :path, :string
      attribute :controller_path, :string
      attribute :action_name, :string
      attribute :request_method, :string
      attribute :referer, :string
      attribute :params, :json, default: {}
      attribute :body, :json, default: {}
      attribute :cookie, :json, default: {}
      attribute :session_id, :string
      attribute :session, :json, default: {}
      attribute :auth_token, :string
      attribute :destroyable, :boolean, default: true
      attribute :skip_back, :boolean, default: false

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_one :organ_domain, class_name: 'Org::OrganDomain', primary_key: [:organ_id, :host], foreign_key: [:organ_id, :host]

      after_find :destroy_after_used, if: -> { destroyable? }
      after_save :destroy_after_used, if: -> { destroyable? && saved_change_to_destroyable? }
      before_destroy :delete_descendants
    end

    def detail
      r = {
        host: host,
        controller: controller_path,
        action: action_name,
        **params.except('auth_token')
      }
      r.merge! auth_token: auth_token if auth_token.present?
      r
    end

    def prev_path
      if parent
        if parent.skip_back
          parent.referer
        else
          parent.path
        end
      else
        referer
      end
    end

    def url(**options)
      if get? && default_path == '/board'
        if organ_domain
          organ_domain.redirect_url(**options)
        else
          default_url(**options)
        end
      elsif get?
        default_url(**options)
      elsif referer.present?
        uri = URI(referer)
        uri.query = URI.encode_www_form(URI.decode_www_form(uri.query.to_s).to_h.merge(**options))
        uri.to_s
      else
        if organ_domain
          organ_domain.redirect_url(**options)
        else
          default_url(**options)
        end
      end
    end

    def default_url(**options)
      Rails.app.routes.url_for(
        host: host,
        controller: controller_path,
        action: action_name,
        **params.compact_blank.symbolize_keys!,
        **options
      )
    end

    def default_path
      Rails.app.routes.url_for(
        controller: controller_path,
        action: action_name,
        only_path: true,
        **params.to_options
      )
    end

    def ancestor_path?(path)
      paths = ancestors.each_with_object({}) { |i, h| h.merge! i.path => i }
      paths.key?(path)
    end

    def ancestor_path(path)
      paths = ancestors.each_with_object({}) { |i, h| h.merge! i.path => i }
      paths[path]
    end

    def destroy_after_used
      StateDestroyJob.perform_later(self.id)
    end

    def path_eql?(params_controller, params_action)
      controller_path.delete_prefix('/') == params_controller && action_name == params_action
    end

    def ident
      "#{controller_path}##{action_name}"
    end

    def get?
      request_method == 'GET'
    end

    def delete_descendants
      descendants.reverse_each(&:destroy)
    end

  end
end
