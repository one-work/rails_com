module Pg
  class StatSubscription < BaseRecord
    self.table_name = 'pg_catalog.pg_stat_subscription'
  end
end
