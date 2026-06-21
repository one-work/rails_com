module Pg
  class BaseRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to shards: {
      default: { writing: :primary, reading: :primary },
      prod: { writing: :prod, reading: :prod }
    }
    #establish_connection schema_search_path: 'pg_catalog'
  end
end
