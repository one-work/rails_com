module Debug::Model
  module One
    extend ActiveSupport::Concern

    included do
      attribute :name, :string

      enum :state, {
        init: 'init',
        confirmed: 'confirmed'
      }, default: 'init'

      has_many :manies, inverse_of: :one
      accepts_nested_attributes_for :manies

      has_one_attached :file
    end
  end
end
