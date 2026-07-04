module Roled
  module Model::RoleType
    extend ActiveSupport::Concern

    included do
      attribute :who_type, :string

      belongs_to :role
    end

    class_methods do

      def who_types
        Roled::RoleType.options_i18n(:who_type).each_with_object([]) do |(value, type), arr|
          arr << OpenStruct.new(type: type, value: value)
        end
      end

    end

  end
end
