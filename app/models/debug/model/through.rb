module Debug::Model
  module Through
    extend ActiveSupport::Concern

    included do
      attribute :name, :string

      belongs_to :many, inverse_of: :throughs
      belongs_to :much
    end
  end
end
