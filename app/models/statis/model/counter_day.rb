module Statis
  module Model::CounterDay
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
      attribute :month, :integer
      attribute :day, :integer
      attribute :year_month, :string, index: true
      attribute :date, :date
      attribute :count, :integer
      attribute :filter, :json

      belongs_to :config, counter_cache: true
      belongs_to :counter_month, foreign_key: [:config_id, :year_month], primary_key: [:config_id, :year_month], optional: true
      belongs_to :counter_year, foreign_key: [:config_id, :year], primary_key: [:config_id, :year], optional: true

      after_initialize :init_year_month, if: -> { new_record? && date.present? }
    end

    def init_year_month
      self.year = date.year
      self.month = date.month
      self.day = date.day
      self.year_month = "#{year}-#{month.to_s.rjust(2, '0')}"
    end

    def time_range
      the_day = Date.new(year, month, day)
      the_day.beginning_of_day ... (the_day + 1).beginning_of_day
    end

    def cache_value
      self.count = config.countable.where(filter).where(created_at: time_range).count
    end

  end
end
