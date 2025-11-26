module Roled
  module Model::Role
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :tip, :string
      attribute :description, :string
      attribute :visible, :boolean, default: false
      attribute :role_hash, :json, default: {}
      attribute :default, :boolean

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :role_whos, dependent: :destroy_async
      has_many :tabs, dependent: :delete_all
      has_many :role_types
      has_many :cache_roles, dependent: :destroy_async
      has_many :caches, through: :cache_roles, source: :cache
      has_many :role_rules, dependent: :delete_all, inverse_of: :role
      has_many :controllers, ->{ distinct }, through: :role_rules
      has_many :busynesses, -> { distinct }, through: :role_rules

      accepts_nested_attributes_for :role_types, allow_destroy: true

      scope :visible, -> { where(visible: true) }
      scope :default, -> { where(default: true) }

      normalizes :tip, with: -> tip { tip.presence }

      validates :name, presence: true

      after_update :set_default, if: -> { default? && saved_change_to_default? }
      after_save :sync, if: -> { saved_change_to_role_hash? }
      after_save :reset_cache!, if: -> { saved_change_to_role_hash? }
    end

    def reset_cache!
      caches.find_each { |i| i.reset_role_hash! }
    end

    def has_role?(business: nil, namespace: nil, controller: nil, action: nil, **params)
      controller = controller.to_s.delete_prefix('/').presence
      business ||= RailsCom::Routes.controller_paths[controller][:business]
      namespace ||= RailsCom::Routes.controller_paths[controller][:namespace] if controller.present?
      opts = [business, namespace, controller, action].take_while(&->(i){ !i.nil? })
      return false if opts.blank?

      r = role_hash.dig(*opts)
      logger.debug "\e[35m  Role: #{opts} is #{r} \e[0m"
      r
    rescue => e
      logger.debug "\e[35m business: #{business}, namespace: #{namespace}, controller: #{controller}, action: #{action}, params: #{params} \e[0m"
    ensure
      0
    end

    def set_default
      self.class.where.not(id: self.id).update_all(default: false)
    end

    def role_types_hash
      role_types.each_with_object({}) do |role_type, h|
        h.merge! role_type.who_type => role_type
      end
    end

    def business_on(meta_business)
      role_hash.deep_merge! meta_business.role_path
    end

    def business_off(business_identifier:)
      role_hash.delete business_identifier.to_s

      role_hash
    end

    def business_role(meta_business)
      r = has_role?(business: meta_business.identifier)

      if r == meta_business.role_hash
        1
      elsif r.blank?
        0
      end
    end

    def namespace_on(meta_namespace, business_identifier)
      role_hash.deep_merge! meta_namespace.role_path(business_identifier)
    end

    def namespace_off(business_identifier:, namespace_identifier:)
      namespaces_hash = role_hash.fetch(business_identifier)
      return if namespaces_hash.blank?
      namespaces_hash.delete(namespace_identifier)

      if namespaces_hash.blank?
        role_hash.delete(business_identifier)
      end

      role_hash
    end

    def namespace_role(meta_namespace, business_identifier = '')
      r = has_role?(
        business: business_identifier,
        namespace: meta_namespace.identifier
      )

      if r == meta_namespace.role_hash(business_identifier)
        1
      elsif r.blank?
        0
      end
    end

    def controller_on(meta_controller)
      role_hash.deep_merge! meta_controller.role_path
    end

    def controller_off(business_identifier:, namespace_identifier:, controller_path:)
      namespaces_hash = role_hash.fetch(business_identifier, {})
      return if namespaces_hash.blank?
      controllers_hash = namespaces_hash.fetch(namespace_identifier, {})
      return if controllers_hash.blank?
      controllers_hash.delete(controller_path)

      if controllers_hash.blank?
        namespaces_hash.delete(namespace_identifier)
      end
      if namespaces_hash.blank?
        role_hash.delete(business_identifier)
      end

      role_hash
    end

    def controller_role(meta_controller)
      r = has_role?(controller: meta_controller.controller_path)
      if r == meta_controller.role_hash
        1
      elsif r.blank?
        0
      end
    end

    def action_on(meta_action)
      role_hash.deep_merge!(meta_action.role_path)
    end

    def action_off(meta_action)
      actions_hash = role_hash.dig(meta_action.business_identifier, meta_action.namespace_identifier, meta_action.controller_path)
      return if actions_hash.blank?

      actions_hash.delete(meta_action.action_name)
      if actions_hash.blank?
        role_hash.dig(meta_action.business_identifier, meta_action.namespace_identifier).delete(meta_action.controller_path)
      end
      if role_hash.dig(meta_action.business_identifier, meta_action.namespace_identifier).blank?
        role_hash.dig(meta_action.business_identifier).delete(meta_action.namespace_identifier)
      end
      if role_hash.dig(meta_action.business_identifier).blank?
        role_hash.delete(meta_action.business_identifier)
      end

      role_hash
    end

    def role_rule_hash
      role_rules.group_by(&:business_identifier).transform_values! do |businesses|
        businesses.group_by(&:namespace_identifier).transform_values! do |namespaces|
          namespaces.group_by(&:controller_path).transform_values! do |controllers|
            controllers.each_with_object({}) { |i, h| h.merge! i.action_name => i.meta_action_id }
          end
        end
      end
    end

    def prune
      c = {}

      businesses = Com::MetaBusiness.where(identifier: role_hash.keys)
      businesses.each do |business|
        r = role_hash.dig(business.identifier).diff_remove(business.role_hash)
        r.each do |namespace_identifier, controllers_hash|
          controllers_hash.each do |controller_path, actions|
            actions.each do |action|
              action_off(action)
            end
          end
        end
        c.merge! business.identifier => r
      end
      self.save

      c
    end

    def sync
      leaves = role_hash.leaves
      rr_ids = role_rules.pluck(:meta_action_id)

      role_rules.where(meta_action_id: rr_ids - leaves).delete_all

      adds = Com::MetaAction.where(id: leaves - rr_ids).each_with_object([]) do |meta_action, arr|
        arr << {
          business_identifier: meta_action.business_identifier,
          namespace_identifier: meta_action.namespace_identifier,
          controller_path: meta_action.controller_path,
          action_name: meta_action.action_name,
          meta_action_id: meta_action.id
        }
      end

      if adds.present?
        role_rules.insert_all(adds)
      end
    end

  end
end
