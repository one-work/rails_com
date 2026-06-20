module Pg
  class ReplicationSlot < BaseRecord
    self.table_name = 'pg_catalog.pg_replication_slots'
  end
end
