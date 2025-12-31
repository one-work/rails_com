module Statis
  module Model::StatisticDay
    extend ActiveSupport::Concern
    include Ext::Day

    included do
      attribute :value, :decimal

      belongs_to :statistic, counter_cache: true
    end

    def cache_value
      self.value = statistic.statistical.sum_from_source(statistic, 'day', date)
    end

  end
end
