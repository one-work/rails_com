module Statis
  module Ext::Week
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
      attribute :cweek, :integer
    end

    def time_range
      date.beginning_of_day ... date.next_day.beginning_of_day
    end

  end
end
