module Pg
  module Model::Publication
    extend ActiveSupport::Concern

    included do
      attribute :pubname, :string

      has_many :publication_tables, primary_key: :pubname, foreign_key: :pubname
    end

    def tables
      publication_tables.pluck(:tablename)
    end

  end
end
