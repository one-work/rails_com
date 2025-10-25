module RailsCom::ActionController
  class Subscriber < ActiveSupport::LogSubscriber
    attach_to :action_controller

    def start_processing(event)
      return unless logger.debug?
      payload = event.payload
      raw_headers = payload.fetch(:headers, {})
      real_headers = Com::Err.request_headers(raw_headers)
      sessions = raw_headers['rack.session'].to_h
      cookies = payload[:request].cookies.except(Rails.configuration.session_options[:key])
      ancestors = payload[:request].controller_class.ancestors.yield_self(&->(i){ i.slice(0...(i.index(ActionController::Base) || i.index(ActionController::API))) })

      debug "\e[33m  Headers:\e[0m { #{real_headers.map(&->(k,v){ "\e[37m#{k}:\e[0m \e[90m#{v}\e[0m" }).join(', ')} }"
      debug "\e[33m  Sessions:\e[0m { #{sessions.map(&->(k,v){ "\e[37m#{k}:\e[0m \e[90m#{v}\e[0m" }).join(', ')} }" unless sessions.blank?
      debug "\e[33m  Cookies:\e[0m { #{cookies.map(&->(k, v){ "\e[37m#{k}:\e[0m \e[90m#{v}\e[0m" }).join(', ')} }" unless cookies.blank?
      debug "\e[33m  Ancestors:\e[0m [#{ancestors.map(&->(i){ i.is_a?(Class) ? "\e[37m#{i}\e[0m" : "\e[90m#{i}\e[0m" }).join(', ')}]"
      debug "\e[33m  Prefixes:\e[0m #{payload[:request].controller_instance.send(:_prefixes)}"
    end

    def process_action(event)
      payload = event.payload

      return if payload[:exception_object].blank?
      return if RailsCom.config.ignore_exception.include?(payload[:exception_object].class.to_s)
      return if Rails.env.development? && RailsCom.config.disable_debug

      err = Com::Err.new
      err.record!(payload)
    end

  end
end
