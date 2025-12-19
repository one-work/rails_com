module Com
  class PgSubscription < PgRecord
    include Model::PgSubscription

    self.table_name = 'pg_catalog.pg_subscription'
    self.primary_key = 'oid'
  end
end
