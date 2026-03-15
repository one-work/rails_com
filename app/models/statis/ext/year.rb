module Statis
  module Ext::Year
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
    end

    def time_range
      begin_on.beginning_of_day ... (begin_on.end_of_year + 1).beginning_of_day
    end

  end
end
