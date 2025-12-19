# frozen_string_literal: true

module RailsCom
  class Engine < ::Rails::Engine #:nodoc:

    config.autoload_paths += Dir[
      "#{config.root}/app/models/role",
      "#{config.root}/app/models/who_role",
      "#{config.root}/app/models/acme_servicer",
      "#{config.root}/app/models/acme_identifier",
      "#{config.root}/app/models/detector_bot",
      "#{config.root}/app/models/detector_log",
      "#{config.root}/app/models/err_bot"
    ]
    config.eager_load_paths += Dir[
      "#{config.root}/app/models/role",
      "#{config.root}/app/models/who_role",
      "#{config.root}/app/models/acme_servicer",
      "#{config.root}/app/models/acme_identifier",
      "#{config.root}/app/models/detector_bot",
      "#{config.root}/app/models/detector_log",
      "#{config.root}/app/models/err_bot"
    ]

    config.generators do |g|
      g.stylesheets false
      g.helper false
      g.resource_route false
      g.jbuilder false
      g.templates.unshift File.expand_path('lib/templates', root)
    end

    config.action_view.field_error_proc = ->(html_tag, instance){ html_tag }

    initializer 'rails_com.add_generator_templates'do |app|
      app.config.paths['lib/templates'].unshift File.expand_path('lib/templates', root)
      # todo check if really works
      app.config.generators do |g|
        g.stylesheets false
        g.helper false
        g.resource_route false
        g.jbuilder true
      end
    end

    initializer 'rails_com.quiet_logs' do |app|
      app.middleware.insert_before ::Rails::Rack::Logger, ::RailsCom::QuietLogs
    end

    initializer 'rails_com.default_initializer' do |app|
      app.config.content_security_policy_nonce_generator = -> request {
        request.headers['X-Csp-Nonce'] || SecureRandom.base64(16)
      }
      app.config.action_dispatch.rescue_responses.merge!({
        'ActionController::ForbiddenError' => :forbidden,
        'ActionController::UnauthorizedError' => :unauthorized
      })
      Mime::Type.register 'image/webp', :webp
      #ActiveStorage::Attached::One.prepend RailsCom::AttachedOne
    end

    initializer 'rails_com.add_json_paths' do
      ActiveSupport.on_load(:action_controller_base) do
        append_view_path RailsCom::Engine.root.join('app/jsons')
      end
    end

    config.to_prepare do
      overrides = RailsCom::Engine.root.join('app/overrides')
      Rails.autoloaders.main.ignore(overrides)
      Dir.glob("#{overrides}/**/*_override.rb").each do |override|
        load override
      end
    end

  end
end
