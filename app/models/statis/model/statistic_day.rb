module Statis
  module Model::StatisticDay
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
      attribute :month, :integer
      attribute :day, :integer
      attribute :year_month, :string, index: true
      attribute :date, :date
      attribute :value, :decimal

      belongs_to :statistic, counter_cache: true

      before_validation :init_year_month, if: -> { (changes.keys & ['date']).present? }
    end

    def init_year_month
      self.year = date.year
      self.month = date.month
      self.day = date.day
      self.year_month = "#{year}-#{month.to_s.rjust(2, '0')}"
    end

    def cache_value
      self.value = statistic.statistical.sum_from_source(statistic, 'day', date)
    end

  end
end
