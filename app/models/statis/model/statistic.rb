module Statis
  module Model::Statistic
    extend ActiveSupport::Concern

    included do
      attribute :statistical_type, :string
      attribute :column, :string
      attribute :extra, :json
      attribute :value, :string
      attribute :cached, :boolean, default: false
      attribute :statistic_years_count, :integer
      attribute :statistic_months_count, :integer
      attribute :statistic_days_count, :integer

      has_many :statistic_years, dependent: :delete_all
      has_many :statistic_months, dependent: :delete_all
      has_many :statistic_days, dependent: :delete_all

      has_one :statistic_config, primary_key: [:statistical_type, :statistical_id], foreign_key: [:statistical_type, :statistical_id]
      has_many :statistic_configs, primary_key: [:statistical_type, :statistical_id], foreign_key: [:statistical_type, :statistical_id]

      scope :to_cache, -> { where(cached: false) }

      after_create_commit :cache_from_config_later
    end

    def cache_from_config_later
      StatisticJob.perform_later(self)
    end

    def cache_from_config
      return unless statistic_config
      cache_statistic_months(start: statistic_config.begin_on, finish: statistic_config.end_on)
      self.update cached: true
    end

    def cache_statistic_months(start:, finish:)
      first_day = start.beginning_of_month
      if start > first_day
        cache_statistic_days(start: start, finish: start.end_of_month)
      end

      next_last_day = start.next_month.end_of_month
      while next_last_day < finish
        cache_statistic_month(next_last_day.to_fs(:year_and_month))
        next_last_day = next_last_day.next_month.end_of_month
      end

      if finish.end_of_month == finish
        cache_statistic_month(finish.to_fs(:year_and_month))
      else
        cache_statistic_days(start: finish.beginning_of_month, finish: finish)
      end
    end

    def cache_statistic_month(year_month)
      year, month = year_month.split('-')
      sm = statistic_months.find_by(year: year, month: month)
      return if sm

      sm = statistic_months.find_or_initialize_by(year: year, month: month)
      sm.cache_value
      sm.save
    end

    def cache_statistic_days(start:, finish:)
      return if start > finish
      (start..finish).each do |date|
        cache_statistic_day(date)
      end
    end

    def cache_statistic_day(date = Date.today - 1)
      sd = statistic_days.find_by(date: date)
      return if sd

      sd = statistic_days.find_or_initialize_by(date: date)
      sd.cache_value
      sd.save
    end

  end
end
