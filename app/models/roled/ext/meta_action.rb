module Roled
  module Ext::MetaAction
    extend ActiveSupport::Concern

    included do
      has_many :role_rules, ->(o) { where(controller_path: o.controller_path) }, class_name: 'Roled::RoleRule', foreign_key: :action_name, primary_key: :action_name
      has_many :roles, class_name: 'Roled::Role', through: :role_rules

      after_destroy_commit :prune_from_role
    end

    def prune_from_role
      roles.each do |role|
        role.action_off(self)
        role.save
      end
    end

  end
end
