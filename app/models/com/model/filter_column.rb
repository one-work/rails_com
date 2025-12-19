module Com
  module Model::FilterColumn
    extend ActiveSupport::Concern

    included do
      attribute :column, :string
      attribute :value, :string

      belongs_to :filter
    end

  end
end
