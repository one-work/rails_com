module Pg
  class User < BaseRecord
    self.table_name = 'pg_catalog.pg_user'
    self.primary_key = 'usesysid'

    has_one :role, foreign_key: :oid
  end
end
