module Meta
  class Data < BaseRecord
    self.table_name = 'ar_internal_metadata'
    attribute :value, :string

  end
end
