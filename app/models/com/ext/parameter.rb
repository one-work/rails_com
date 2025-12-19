module Com
  module Ext::Parameter
    extend ActiveSupport::Concern

    included do
      attribute :parameters, :json, default: {}
    end

    def form_parameters
      parameters.each_with_object([]) { |(k, v), arr| arr << OpenStruct.new(key: k, value: v) }
    end

  end
end
