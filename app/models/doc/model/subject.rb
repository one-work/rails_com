module Doc
  module Model::Subject
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :controller_path, :string
      attribute :action_name, :string
      attribute :path_params, :json
      attribute :request_params, :json
      attribute :request_comments, :json
      attribute :request_headers, :json
      attribute :request_type, :string
      attribute :request_body, :json
      attribute :response_status, :integer, default: 200
      attribute :response_headers, :json
      attribute :response_type, :string
      attribute :response_body, :json
      attribute :response_comments, :json
      attribute :note, :string
      attribute :synced_at, :datetime

      belongs_to :meta_action, class_name: 'Meta::Action', foreign_key: [:controller_path, :action_name], primary_key: [:controller_path, :action_name], optional: true
    end

    def base_url(request = nil)
      options = {}
      if request
        options.merge! scheme: request.scheme, host: request.host
        options.merge! port: request.port unless [80, 443].include?(request.port)
      end
      options.merge! Rails.application.routes.default_url_options
      if options.key?(:protocol)
        options.merge! scheme: options[:protocol]
      end

      URI::Generic.build(**options).to_s
    end

    class_methods do

      def sync(now = Time.current)
        docs_hash.each do |controller_path, action_names|
          action_names.each do |action_name, comments|
            subject = self.find_or_initialize_by(controller_path: controller_path, action_name: action_name)
            subject.response_comments = comments
            subject.synced_at = now
            subject.save
          end
        end
        where(synced_at: ...now).delete_all
      end

      def docs_hash
        if Rails.root.join('config/doc.yml').exist?
          doc_hash = YAML.load_file(Rails.root.join('config/doc.yml'))
        else
          doc_hash = {}
        end

        Rails::Engine.subclasses.each_with_object(doc_hash) do |engine, h|
          doc_path = engine.root.join('config/doc.yml')
          if doc_path.exist?
            YAML.safe_load_file(doc_path).each do |k, v|
              h[k] ||= {}
              h[k].merge! v
            end
          end
        end
      end

    end

  end
end
