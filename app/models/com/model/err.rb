module Com
  module Model::Err
    extend ActiveSupport::Concern

    included do
      attribute :path, :string
      attribute :controller_name, :string
      attribute :action_name, :string
      attribute :exception, :string
      attribute :exception_object, :string
      attribute :exception_backtrace, :json, default: []
      attribute :params, :json, default: {}
      attribute :headers, :json, default: {}
      attribute :cookie, :json, default: {}
      attribute :session, :json, default: {}
      attribute :ip, :string

      belongs_to :err_summary, ->(o){ where(o.filter_hash) }, foreign_key: :controller_name, primary_key: :controller_name, counter_cache: true, touch: true, optional: true
      has_many :err_notices, primary_key: :controller_name, foreign_key: :controller_name
      has_many :err_bots, through: :err_notices

      default_scope -> { order(id: :desc) }

      before_create :sync_to_summary
      after_create_commit :send_message_later
    end

    def filter_hash
      {
        action_name: action_name,
        exception_object: exception_object
      }
    end

    def send_message
      err_bots.map do |bot|
        bot.send_message(self)
      end
    end

    def send_first_message
      ErrBot.first_time.map do |bot|
        bot.send_message(self)
      end
    end

    def send_message_later
      if err_bots.present?
        ErrJob.perform_later(self)
      elsif err_summary.errs_count == 1
        ErrFirstJob.perform_later(self)
      end
    end

    def user_info
      token = session.dig('auth_token') || headers.dig('AUTH_TOKEN')
      return {} unless defined? Auth::AuthorizedToken
      at = Auth::AuthorizedToken.find_by id: token
      if at&.user
        at.user.as_json(only: [:id, :name], methods: [:account_identities])
      elsif at&.account
        at.account.as_json(only: [:id, :identity])
      else
        {}
      end
    end

    def record(payload)
      self.path = payload[:path]
      self.controller_name = payload[:controller]
      self.action_name = payload[:action]
      self.exception = payload[:exception].join("\r\n")[0..self.class.columns_limit['exception']]
      self.exception_object = payload[:exception_object].class.to_s
      self.exception_backtrace = payload[:exception_object].backtrace.map(&->(i){ i.delete_prefix("#{Gem.path[0]}/") })
      self.params = self.class.filter_params(payload[:params])

      raw_headers = payload.fetch(:headers, {})
      self.headers = self.class.request_headers(raw_headers)
      self.ip = raw_headers['action_dispatch.remote_ip'].to_s
      self.cookie = raw_headers['rack.request.cookie_hash']
      self.session = raw_headers['rack.session'].to_h
    end

    def record!(payload)
      record(payload)
      save
      self
    end

    def sync_to_summary
      err_summary || create_err_summary
    end

    def clean_other
      err_summary.errs.where.not(id: id).delete_all
    end

    class_methods do
      def record_to_log(controller, exp)
        return if Rails.env.development? && RailsCom.config.disable_debug
        request = controller.request

        lc = self.new
        payload = {
          path: request.fullpath,
          controller: controller.class.name,
          action: controller.action_name,
          params: request.filtered_parameters,
          headers: request.headers,
          exception: [exp.class.name, exp.message],
          exception_object: exp
        }
        lc.record!(payload)
      end

      def request_headers(headers)
        result = headers.select { |k, _| k.start_with?('HTTP_') && k != 'HTTP_COOKIE' }
        result = result.collect { |pair| [pair[0].sub(/^HTTP_/, ''), pair[1]] }
        result.sort.to_h
      end

      def filter_params(params)
        params.deep_transform_values(&:to_s).except('controller', 'action')
      end

      def columns_limit
        @columns_limit ||= self.columns_hash.slice(
          'params',
          'headers',
          'cookie',
          'session',
          'exception',
          'exception_object',
          'exception_backtrace'
        ).transform_values { |i| i.limit.nil? ? -1 : i.limit - 1 }
      end
    end

  end
end
