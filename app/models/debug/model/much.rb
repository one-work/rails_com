module Debug::Model
  module Much
    extend ActiveSupport::Concern

    included do
      attribute :name, :string

      has_many :throughs
      has_many :manies, through: :throughs

      accepts_nested_attributes_for :throughs
    end
  end
end
