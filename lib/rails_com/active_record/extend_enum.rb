# frozen_string_literal: true

module RailsCom::ActiveRecord
  module ExtendEnum

    def options_i18n(attribute)
      h = enum_base_i18n(attribute)

      if h.is_a?(Hash) && h.present?
        return h.invert
      end

      if h.blank?
        name = attribute.to_s.pluralize
        if respond_to?(name)
          enum_hash = public_send(name)
          h = enum_hash.keys.map { |i| [i.humanize, i] }.to_h
        end
      end

      h
    end

    def options_i18n_for_collection(attribute)
      options_i18n(attribute).each_with_object([]) do |(value, type), arr|
        arr << OpenStruct.new(value: type.to_s, name: value)
      end
    end

    def enum_base_i18n(attribute)
      h = ::I18n.t enum_key(attribute), default: {}
      h.compact  # 注意这里返回的结果是 frozen Hash, 避免使用 compact!
    end

    def enum_i18n(attribute, value)
      h = enum_base_i18n(attribute)
      v = nil

      if h.is_a?(Hash)
        v = h[value] ? h[value] : h[value.to_s.to_sym]
      end

      if v.nil? && value.blank?
        v = value.to_s
      end

      if v.nil?
        v = human_attribute_name(value)
      end

      v
    end

    def enum_key(attribute)
      RailsCom.config.enum_key.call(self, attribute)
    end

    def self.extended(mod)
      mod.attribute_method_suffix '_i18n'

      mod.class_exec do
        def attribute_i18n(attr)
          if [:json, :jsonb].include? self.class.columns_hash[attr]&.type
            send(attr)&.transform_keys! { |key| self.class.human_attribute_name(key) }
          else
            self.class.enum_i18n attr, send(attr)
          end
        end
      end
    end

  end
end

ActiveSupport.on_load :active_record do
  extend RailsCom::ActiveRecord::ExtendEnum
end
