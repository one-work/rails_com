module Roled
  module Model::Cache
    extend ActiveSupport::Concern

    included do
      attribute :str_role_ids, :string, index: true
      attribute :role_hash, :json, default: {}
      attribute :business_hash, :json, default: {}
      attribute :who_type, :string

      has_many :cache_roles, dependent: :delete_all
      has_many :roles, through: :cache_roles

      before_save :sync_to_business_hash, if: -> { role_hash_changed? }
      after_save :sync_role_caches, if: -> { saved_change_to_str_role_ids? }
      after_destroy :change_caches
    end

    def sync_to_business_hash
      r = Meta::Controller.select(:business_identifier, :namespace_identifier).distinct.where(controller_path: role_hash.keys).pluck(:business_identifier, :namespace_identifier)
      self.business_hash = r.to_array_h.to_combine_h
    end

    def sync_role_caches
      self.role_ids = str_role_ids.split(',')
      reset_role_hash!
    end

    def reset_role_hash!
      self.role_hash = compute_role_hash
      self.save
    end

    def compute_role_hash
      (roles + default_roles).uniq.each_with_object({}) do |role, h|
        h.deep_merge! role.role_hash
      end
    end

    def default_roles
      Role.joins(:role_types).where(role_types: { who_type: who_type }).default
    end

    def change_caches
      who_type.constantize.where(cache_id: id).find_each { |who| who.compute_role_cache! }
    end

  end
end
