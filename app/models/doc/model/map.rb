module Doc
  module Model::Map
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :mappings, :json
    end

  end
end
