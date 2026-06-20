module Pg
  class Namespace < BaseRecord
    self.table_name = 'pg_catalog.pg_namespace'
  end
end
