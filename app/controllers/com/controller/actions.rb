# frozen_string_literal: true

module Com
  module Controller::Actions
    extend ActiveSupport::Concern

    def actions
      render :actions, locals: { model: model_object }
    end

    private
    def model_object
      if instance_variable_defined? "@#{model_name}"
        instance_variable_get "@#{model_name}"
      end
    end

    def model_name
      controller_name.singularize
    end

  end
end
