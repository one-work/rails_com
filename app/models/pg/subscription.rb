module Pg
  class Subscription < PgRecord
    include Model::Subscription

    self.table_name = 'pg_catalog.pg_subscription'
    self.primary_key = 'oid'
  end
end
