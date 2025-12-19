module Com
  class PgReplicationSlot < PgRecord
    self.table_name = 'pg_catalog.pg_replication_slots'
  end
end
