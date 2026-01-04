module Doc
  class BaseRecord < ActiveRecord::Base
    self.abstract_class = true
    #connects_to database: { writing: :x }
  end
end
