module Pg
  class Namespace < PgRecord
    self.table_name = 'pg_catalog.pg_namespace'
  end
end
