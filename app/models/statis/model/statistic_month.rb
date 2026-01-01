module Statis
  module Model::StatisticMonth
    extend ActiveSupport::Concern
    include Ext::Month

    included do
      attribute :value, :decimal

      belongs_to :statistic, counter_cache: true
    end

    def cache_value
      today = Date.today

      if today.to_fs(:year_and_month) == year_month
        statistic.cache_statistic_days(start: today.beginning_of_day, finish: today - 1)
      else
        self.value = statistic.statistical.sum_from_source(statistic, 'month', today.change(year: year, month: month, day: 1))
      end
    end

  end
end
