module Pg
  class Role < BaseRecord
    self.table_name = 'pg_catalog.pg_roles'
    self.primary_key = 'oid'
  end
end
