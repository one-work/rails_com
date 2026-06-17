module Roled
  module Model::RoleRule
    extend ActiveSupport::Concern

    included do
      attribute :business_identifier, :string, default: ''
      attribute :namespace_identifier, :string, default: ''
      attribute :controller_path, :string
      attribute :action_name, :string
      attribute :identifier, :string, index: true
      attribute :params_name, :string
      attribute :params_identifier, :string

      belongs_to :role, inverse_of: :role_rules
      belongs_to :meta_action, class_name: 'Meta::Action', foreign_key: :identifier, primary_key: :identifier
      belongs_to :meta_business, class_name: 'Meta::Business', foreign_key: :business_identifier, primary_key: :identifier, optional: true
      belongs_to :meta_namespace, class_name: 'Meta::Namespace', foreign_key: :namespace_identifier, primary_key: :identifier, optional: true
      belongs_to :meta_controller, class_name: 'Meta::Controller', foreign_key: :controller_path, primary_key: :controller_path, optional: true
    end

  end
end
