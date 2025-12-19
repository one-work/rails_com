module Statis
  module Model::CounterMonth
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
      attribute :month, :integer
      attribute :year_month, :string, index: true
      attribute :count, :integer
      attribute :filter, :json

      belongs_to :config, counter_cache: true
      belongs_to :counter_year, foreign_key: [:config_id, :year], primary_key: [:config_id, :year], optional: true

      after_initialize :init_year_month, if: :new_record?
    end

    def init_year_month
      self.year_month = "#{year}-#{month.to_s.rjust(2, '0')}"
    end

    def time_range
      the_day = Date.new(year, month, 1)
      the_day.beginning_of_day ... (the_day + 1.month).beginning_of_day
    end

    def cache_value
      self.count = config.countable.where(filter).where(created_at: time_range).count
    end

  end
end
