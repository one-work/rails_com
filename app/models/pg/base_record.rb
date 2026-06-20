module Pg
  class BaseRecord < ActiveRecord::Base
    self.abstract_class = true
    #establish_connection schema_search_path: 'pg_catalog'
  end
end
