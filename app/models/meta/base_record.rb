module Meta
  class BaseRecord < ApplicationRecord
    self.abstract_class = true
    connects_to database: { writing: :prod }
  end
end
