module Roled
  module Model::RoleType
    extend ActiveSupport::Concern

    included do
      attribute :who_type, :string

      belongs_to :role

      has_many :caches, class_name: 'Cache', primary_key: :who_type, foreign_key: :who_type

      after_create :reset_role_cache!
      after_destroy :reset_role_cache!
    end

    def reset_role_cache!
      caches.find_each { |i| i.reset_role_hash! }
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
