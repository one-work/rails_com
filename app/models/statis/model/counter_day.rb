module Statis
  module Model::CounterDay
    extend ActiveSupport::Concern
    include Ext::Day

    included do
      attribute :year, :integer
      attribute :month, :integer
      attribute :day, :integer
      attribute :date, :date
      attribute :year_month, :string, index: true
      attribute :count, :integer
      attribute :values, :json, default: {}

      belongs_to :config, polymorphic: true
      belongs_to :counter_month, foreign_key: [:conter_type, :config_id, :year_month], primary_key: [:conter_type, :config_id, :year_month], optional: true
      belongs_to :counter_year, foreign_key: [:config_id, :year], primary_key: [:config_id, :year], optional: true

      after_initialize :init_year_month, if: -> { new_record? && date.present? }
    end

    def init_year_month
      self.year = date.year
      self.month = date.month
      self.day = date.day
      self.year_month = date.to_fs :year_and_month
    end

    def time_range
      date.beginning_of_day ... date.next_day.beginning_of_day
    end

    def cache_count
      self.count = config.countable.where(filter).where(created_at: time_range).count
    end

    def cache_values
      self.value = statistic.statistical.sum_from_source(statistic, 'day', date)
    end

  end
end
