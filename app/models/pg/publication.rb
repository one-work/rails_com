module Pg
  class Publication < BaseRecord
    include Model::Publication

    self.table_name = 'pg_catalog.pg_publication'
    self.primary_key = 'oid'
  end
end
