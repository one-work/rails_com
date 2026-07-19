module Roled
  module Model::Cache
    extend ActiveSupport::Concern

    included do
      attribute :str_role_ids, :string, index: true
      attribute :roles_arr, :json, default: []
      attribute :role_hash, :json, default: {}
      attribute :business_hash, :json, default: {}
      attribute :who_type, :string
      attribute :mock, :boolean, default: false

      has_many :cache_roles, dependent: :delete_all
      has_many :roles, through: :cache_roles

      before_save :sync_to_business_hash, if: -> { role_hash_changed? }
      before_save :sync_to_str_roles, if: -> { str_role_ids_changed? }
      after_save :sync_role_caches, if: -> { saved_change_to_str_role_ids? }
      after_destroy :change_caches
    end

    def sync_to_business_hash
      r = Meta::Controller.select(:business_identifier, :namespace_identifier).distinct.where(controller_path: role_hash.keys).pluck(:business_identifier, :namespace_identifier)
      result = r.each_with_object({}) do |(k, v), h|
        h.merge! k => h.fetch(k, []) << v
      end
      self.business_hash = result
    end

    def sync_to_str_roles
      self.roles_arr = Role.where(id: str_role_ids.split(',')).pluck(:name)
    end

    def sync_role_caches
      self.role_ids = str_role_ids.split(',')
      reset_role_hash!
    end

    def reset_role_hash!
      self.role_hash = compute_role_hash
      self.save
    end

    def default_hash
      h1 = Role.default_hash(who_type)
      h2 = Role.default_hash

      keys = h1.keys | h2.keys
      keys.each_with_object({}) do |con, h|
        h.merge! con => h1.fetch(con, []) | h2.fetch(con, [])
      end
    end

    def compute_role_hash
      h1 = roles.each_with_object({}) do |role, h|
        role.role_hash.each do |con, actions|
          h.merge! con => h.fetch(con, []) | actions
        end
      end
      h2 = default_hash

      keys = h1.keys | h2.keys
      keys.each_with_object({}) do |con, h|
        h.merge! con => h1.fetch(con, []) | h2.fetch(con, [])
      end
    end

    def change_caches
      who_type.constantize.where(cache_id: id).find_each { |who| who.compute_role_cache! }
    end

    class_methods do

      def reset!
        find_each do |cache|
          cache.reset_role_hash!
        end
      end

    end

  end
end
