module Meta
  class BaseRecord < ActiveRecord::Base
    self.abstract_class = true
    if Rails.env.test?
      connects_to database: { writing: :prod }
    end
  end
end
