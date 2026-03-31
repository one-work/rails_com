# frozen_string_literal: true

module RailsCom::ActiveRecord
  module AbstractAdapter

    def truncate_tables(*table_names)
      table_names -= Meta::BaseRecord.subclasses.map(&:table_name)
      table_names -= Doc::BaseRecord.subclasses.map(&:table_name)

      super
    end

  end
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(RailsCom::ActiveRecord::AbstractAdapter)
