module RailsCom
  class QuietLogs

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'].start_with? *RailsCom.config.quiet_logs
        Rails.logger.debug "\e[33m  Silenced: #{env['PATH_INFO']}  \e[0m"
        Rails.logger.silence { @app.call(env) }
      else
        @app.call(env)
      end
    end

  end
end
