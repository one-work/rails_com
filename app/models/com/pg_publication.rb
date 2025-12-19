module Com
  class PgPublication < PgRecord
    include Model::PgPublication

    self.table_name = 'pg_catalog.pg_publication'
    self.primary_key = 'oid'
  end
end
