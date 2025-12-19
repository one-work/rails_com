module Statis
  module Model::StatisticMonth
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
      attribute :month, :integer
      attribute :year_month, :string, index: true
      attribute :value, :decimal

      belongs_to :statistic, counter_cache: true

      before_validation :init_year_month, if: -> { (changes.keys & ['year', 'month']).present? }
    end

    def init_year_month
      self.year_month = "#{year}-#{month.to_s.rjust(2, '0')}"
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
