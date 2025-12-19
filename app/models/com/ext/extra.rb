module Com
  module Ext::Extra
    extend ActiveSupport::Concern

    included do
      attribute :extra, :json, default: {}
    end

    def form_extra
      r = extra.each_with_object({}) do |(k, v), h|
        h.merge! k => v.send(DefaultForm.config.mapping.dig(taxon.parameters[k].to_sym, :output))
      end

      OpenStruct.new(r)
    end

  end
end
