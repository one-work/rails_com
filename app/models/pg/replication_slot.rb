module Pg
  class ReplicationSlot < BaseRecord
    self.table_name = 'pg_catalog.pg_replication_slots'
    self.primary_key = 'slot_name'
  end
end
