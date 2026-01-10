module Doc
  class BaseRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: { writing: :prod }
  end
end
