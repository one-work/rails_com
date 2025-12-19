module Roled
  module Model::RoleRule
    extend ActiveSupport::Concern

    included do
      attribute :business_identifier, :string, default: ''
      attribute :namespace_identifier, :string, default: ''
      attribute :controller_path, :string
      attribute :action_name, :string
      attribute :params_name, :string
      attribute :params_identifier, :string

      belongs_to :role, inverse_of: :role_rules
      belongs_to :meta_action, class_name: 'Com::MetaAction'
      belongs_to :meta_business, class_name: 'Com::MetaBusiness', foreign_key: :business_identifier, primary_key: :identifier, optional: true
      belongs_to :meta_namespace, class_name: 'Com::MetaNamespace', foreign_key: :namespace_identifier, primary_key: :identifier, optional: true
      belongs_to :meta_controller, class_name: 'Com::MetaController', foreign_key: :controller_path, primary_key: :controller_path, optional: true

      belongs_to :proxy_meta_action, ->(o){ where(controller_path: o.controller_path) }, class_name: 'Com::MetaAction', foreign_key: :action_name, primary_key: :action_name, optional: true
    end

    def fix_rule_relation
      self.meta_action = proxy_meta_action
      self.save
    end

  end
end
