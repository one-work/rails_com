module Pg
  class User < BaseRecord
    self.table_name = 'pg_catalog.pg_user'
    self.primary_key = 'usesysid'
  end
end
