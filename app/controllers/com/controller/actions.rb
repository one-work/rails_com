# frozen_string_literal: true

module Com
  module Controller::Actions
    extend ActiveSupport::Concern

    included do
      helper_method :model_klass, :pluralize_model_name
    end

    def actions
      render :actions, locals: { model: model_object }
    end

    private
    def model_klass
      if self.class.root_module.const_defined?(controller_name.classify)
        self.class.root_module.const_get(controller_name.classify)
      else
        nil
      end
    end

    def model_object
      if instance_variable_defined? "@#{model_name}"
        instance_variable_get "@#{model_name}"
      end
    end

    def pluralize_model_name
      controller_name.pluralize
    end

    def model_name
      controller_name.singularize
    end

  end
end
