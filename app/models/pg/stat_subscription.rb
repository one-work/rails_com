module Pg
  class StatSubscription < PgRecord
    self.table_name = 'pg_catalog.pg_stat_subscription'
  end
end
