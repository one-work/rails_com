module Roled
  module Ext::Base
    extend ActiveSupport::Concern

    included do
      belongs_to :cache, class_name: 'Roled::Cache', optional: true
      belongs_to :mock_cache, class_name: 'Roled::Cache', optional: true

      has_many :role_whos, class_name: 'Roled::RoleWho', as: :who
      has_many :roles, class_name: 'Roled::Role', through: :role_whos

      accepts_nested_attributes_for :role_whos, allow_destroy: true, reject_if: ->(attributes){ attributes.slice('role_id').blank? }

      has_many :role_rules, class_name: 'Roled::RoleRule', through: :roles
      has_many :tabs, class_name: 'Roled::Tab', through: :roles
      has_many :meta_actions, class_name: 'Roled::MetaAction', through: :role_rules

      after_create_commit :compute_role_cache!
    end

    def compute_role_cache!
      str_role_ids = roles.normal.pluck(:id).sort
      cache = Cache.find_or_create_by!(str_role_ids: str_role_ids.join(','))

      mock_ids = roles.mockable.pluck(:id).sort
      mock_cache = Cache.find_or_create_by!(str_role_ids: mock_ids.join(','))

      self.update_columns cache_id: cache.id, mock_cache_id: mock_cache.id  # 资源新增时，防止回调污染
    end

    def visible_roles
      self.class.visible_roles
    end

    def role_whos_hash
      role_whos.each_with_object({}) do |role_who, h|
        h.merge! role_who.role_id => role_who
      end
    end

    def role_whos_attributes
      arr = role_whos.each_with_object([]) do |role_who, h|
        h << {
          role_id: role_who.role_id
        }
      end
      {
        role_whos_attributes: arr
      }
    end

    def role_hash
      cache&.role_hash || {}
    end

    def business_hash
      cache&.business_hash || {}
    end

    def has_role?(**options)
      if admin?
        logger.debug "\e[35m  #{base_class_name}_#{id} is admin!  \e[0m" if Rails.configuration.x.role_debug
        return true
      end

      if options.blank?
        logger.debug "\e[35m  #{base_class_name}_#{id} not has role: #{options}  \e[0m"
        return false
      end
      r = role_hash.fetch(options[:controller].to_s.delete_prefix('/'), []).include? options[:action]
      logger.debug "\e[35m  #{base_class_name}_#{id} has role: #{options}, #{r}  \e[0m" if Rails.configuration.x.role_debug
      r
    end

    def any_role?(business: nil, namespace: nil, controller: nil)
      if admin?
        return true
      end

      if controller
        role_hash[controller].present?
      elsif business && namespace
        business_hash.fetch(business, []).include?(namespace)
      elsif business
        business_hash[business].present?
      else
        false
      end
    end

    def landmark_rules
      _rule_ids = role_hash.leaves
      Meta::Action.where(id: _rule_ids, landmark: true)
    end

    class_methods do
      def visible_roles
        Role.joins(:role_types).where(role_types: { who_type: name }).visible
      end

      def reset_role_cache!
        find_each { |i| i.compute_role_cache! }
      end
    end

  end
end
