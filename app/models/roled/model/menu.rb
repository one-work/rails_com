module Roled
  module Model::Menu
    extend ActiveSupport::Concern

    included do
      attribute :controller_path, :string
      attribute :action_name, :string, default: 'index'
      attribute :identifier, :string
      attribute :icon, :string
      attribute :position, :integer
      attribute :namespace, :string

      belongs_to :role

      positioned on: [:role_id]
    end

    def real_path(**options)

    end

  end
end
