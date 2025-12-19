module Roled
  module Model::Tab
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :path, :string
      attribute :icon, :string
      attribute :position, :integer
      attribute :namespace, :string

      belongs_to :role

      positioned on: [:role_id]
    end

  end
end
