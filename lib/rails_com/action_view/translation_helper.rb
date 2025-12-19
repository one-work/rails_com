# frozen_string_literal: true

module RailsCom::ActionView
  module TranslationHelper

    def t(key, **options)
      options[:default] ||= default_keys(key)
      super
    end

    def default_keys(key)
      suffixes = key.to_s.delete_prefix('.').split('.')
      _key = suffixes.pop
      _action_name = suffixes.pop || action_name
      _controller_name = suffixes.pop
      keys = []
      if key.start_with?('.')
        if _controller_name
          _paths = controller_path.split('/')
          _paths[-1] = _controller_name
          _controller_path = _paths.join('/')
          _controller = _controller_path.to_controller

          until _controller do
            _paths.pop
            break if _paths.blank?
            _paths[-1] = _controller_name
            _controller_path = _paths.join('/')
            _controller = _controller_path.to_controller
          end
        else
          _controller_path = controller_path
          _controller = controller.class
        end

        if _controller
          keys << _controller_path
          super_class = _controller.superclass

          while RailsCom::Routes.controllers[super_class.controller_path]&.key?(_action_name)
            keys << super_class.controller_path
            super_class = super_class.superclass
            break if super_class == ActionController::Base
          end
        end
      end
      keys.map! do |con|
        r = con.split('/')
        r.pop(suffixes.size)
        r.concat(suffixes).append(_action_name, _key).join('.').to_sym
      end

      keys << "controller.#{_action_name}.#{_key}".to_sym
      Rails.logger.debug "\e[35m  I18n: #{keys}  \e[0m" if RailsCom.config.debug_i18n
      keys
    end

  end
end

ActiveSupport.on_load :action_view do
  include RailsCom::ActionView::TranslationHelper
end
