module Roled
  module Ext::Base
    extend ActiveSupport::Concern

    included do
      belongs_to :cache, class_name: 'Roled::Cache', optional: true

      has_many :role_whos, class_name: 'Roled::RoleWho', as: :who
      has_many :roles, class_name: 'Roled::Role', through: :role_whos

      accepts_nested_attributes_for :role_whos, allow_destroy: true, reject_if: ->(attributes){ attributes.slice('role_id').blank? }

      has_many :role_rules, class_name: 'Roled::RoleRule', through: :roles
      has_many :tabs, class_name: 'Roled::Tab', through: :roles
      has_many :meta_actions, class_name: 'Roled::MetaAction', through: :role_rules

      after_create_commit :compute_role_cache!
    end

    def compute_role_cache!
      cache = Cache.find_or_create_by!(str_role_ids: role_ids.join(','), who_type: base_class_name)
      self.update_columns cache_id: cache.id  # 资源新增时，防止回调污染
    end

    def visible_roles
      self.class.visible_roles
    end

    def role_whos_hash
      role_whos.each_with_object({}) do |role_who, h|
        h.merge! role_who.role_id => role_who
      end
    end

    def role_hash
      cache&.role_hash || {}
    end

    def has_role?(**options)
      if admin?
        logger.debug "\e[35m  #{base_class_name}_#{id} is admin!  \e[0m" if Rails.configuration.x.role_debug
        return true
      end

      options[:business] = options[:business].to_s if options.key?(:business)
      options[:namespace] = options[:namespace].to_s if options.key?(:namespace)

      opts = [options[:business], options[:namespace], options[:controller].to_s.delete_prefix('/').presence, options[:action]].take_while(&->(i){ !i.nil? })
      if opts.blank?
        logger.debug "\e[35m  #{base_class_name}_#{id} not has role: #{opts}  \e[0m"
        return false
      end
      r = role_hash.dig(*opts)
      logger.debug "\e[35m  #{base_class_name}_#{id} has role: #{opts}, #{r}  \e[0m" if Rails.configuration.x.role_debug
      r
    end

    def any_role?(*any_roles, **roles_hash)
      if admin?
        return true
      end

      if (any_roles.map(&:to_s) & rails_role.keys).present?
        return true
      end

      roles_hash.stringify_keys!
      roles_hash.slice(*rails_role.keys).each do |govern, rules|
        h_keys = rails_role[govern].select { |i| i }.keys
        rules = Array(rules).map(&:to_s)
        return true if (h_keys & rules).present?
      end

      false
    end

    def landmark_rules
      _rule_ids = role_hash.leaves
      Com::MetaAction.where(id: _rule_ids, landmark: true)
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
