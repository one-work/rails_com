module Roled
  module Model::Role
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :tip, :string
      attribute :description, :string
      attribute :visible, :boolean, default: false
      attribute :role_hash, :json, default: {}
      attribute :business_hash, :json, default: {}
      attribute :default, :boolean, default: false
      attribute :subdomain, :string

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

      before_save :sync_to_business_hash, if: -> { role_hash_changed? }
      after_save :sync, if: -> { saved_change_to_role_hash? }
      after_save :reset_cache!, if: -> { saved_change_to_role_hash? }
      after_save :reset_type_cache!, if: -> { saved_change_to_default? }
      after_destroy :destroy_cache!
    end

    def sync_to_business_hash
      r = Meta::Controller.select(:business_identifier, :namespace_identifier).distinct.where(controller_path: role_hash.keys).pluck(:business_identifier, :namespace_identifier)
      self.business_hash = r.to_array_h.to_combine_h
    end

    def reset_cache!
      if default
        reset_type_cache!
      else
        caches.find_each { |i| i.reset_role_hash! }
      end
    end

    def destroy_cache!
      if default
        reset_type_cache!
      else
        caches.each(&:destroy)
      end
    end

    def reset_type_cache!
      role_types.each { |i| i.reset_role_cache! }
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

    def role_types_hash
      role_types.each_with_object({}) do |role_type, h|
        h.merge! role_type.who_type => role_type
      end
    end

    def business_on(business_identifier)
      meta_controllers = Meta::Controller.includes(:actions).where(business_identifier: business_identifier.to_s)
      all = meta_controllers.each_with_object({}) { |i, h| h.merge! i.controller_path => i.actions.pluck(:action_name) }

      role_hash.merge! all
    end

    def business_off(business_identifier)
      controller_paths = Meta::Controller.where(business_identifier: business_identifier.to_s)
      role_hash.except!(*controller_paths)

      role_hash
    end

    def business_role(meta_business)
      r1 = meta_business.actions.pluck(:identifier)
      r2 = role_rules.where(business_identifier: meta_business.identifier).pluck(:identifier)

      r = r1 - r2
      if r2.blank?
        0  # 空白
      elsif r.blank?
        1  # 都已选
      else
        -1
      end
    end

    def namespace_role(meta_namespace, business_identifier = '')
      r1 = Meta::Action.where(business_identifier: business_identifier, namespace_identifier: meta_namespace.identifier).pluck(:identifier)
      r2 = role_rules.where(business_identifier: business_identifier, namespace_identifier: meta_namespace.identifier).pluck(:identifier)
      r = r1 - r2

      if r2.blank?
        0
      elsif r.blank?
        1
      else
        -1
      end
    end

    def controller_role(meta_controller)
      r1 = meta_controller.actions.pluck(:action_name)
      r2 = role_hash.fetch(meta_controller.controller_path, [])
      r = r1 - r2

      if r2.blank?
        0
      elsif r.blank?
        1
      else
        -1
      end
    end

    def namespace_on(business_identifier, namespace_identifier)
      meta_controllers = Meta::Controller.includes(:actions).where(business_identifier: business_identifier.to_s, namespace_identifier: namespace_identifier)
      all = meta_controllers.each_with_object({}) { |i, h| h.merge! i.controller_path => i.actions.pluck(:action_name) }

      role_hash.merge! all
    end

    def namespace_off(business_identifier, namespace_identifier)
      controller_paths = Meta::Controller.where(business_identifier: business_identifier.to_s, namespace_identifier: namespace_identifier).pluck(:controller_path)
      role_hash.except!(*controller_paths)

      role_hash
    end

    def controller_on(meta_controller)
      role_hash.merge! meta_controller.role_item
    end

    def controller_off(meta_controller)
      role_hash.delete(meta_controller.controller_path)
      role_hash
    end

    def action_on(meta_action)
      exist = role_hash.fetch(meta_action.controller_path, [])
      exist << meta_action.action_name unless exist.include?(meta_action.action_name)

      role_hash.merge! meta_action.controller_path => exist
    end

    def action_off(meta_action)
      exist = role_hash.fetch(meta_action.controller_path, [])
      exist.delete(meta_action.action_name)

      if exist.blank?
        role_hash.delete(meta_action.controller_path)
      else
        role_hash.merge! meta_action.controller_path => exist
      end

      role_hash
    end

    def role_rule_hash
      role_rules.group_with_arr(:controller_path, :action_name)
    end

    def prune
      c = {}

      businesses = Meta::Business.where(identifier: role_hash.keys)
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

    def all_identifiers
      role_hash.each_with_object([]) do |(con, actions), arr|
        actions.each do |action|
          arr << "#{con}##{action}"
        end
      end
    end

    def sync
      leaves = all_identifiers
      rr_ids = role_rules.pluck(:identifier)

      removes = rr_ids - leaves
      if removes.present?
        role_rules.where(identifier: removes).delete_all
      end

      adds = Meta::Action.where(identifier: leaves - rr_ids).each_with_object([]) do |meta_action, arr|
        arr << {
          business_identifier: meta_action.business_identifier,
          namespace_identifier: meta_action.namespace_identifier,
          controller_path: meta_action.controller_path,
          action_name: meta_action.action_name,
          identifier: meta_action.identifier
        }
      end

      if adds.present?
        role_rules.insert_all(adds)
      end
    end

  end
end
