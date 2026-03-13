module Statis
  module Model::CounterMonth
    extend ActiveSupport::Concern
    include Ext::Month

    included do
      attribute :count, :integer

      belongs_to :config, polymorphic: true, counter_cache: true

      belongs_to :counter_year, foreign_key: [:config_type, :config_id, :year], primary_key: [:config_type, :config_id, :year], optional: true
    end

    def time_range
      the_day = Date.new(year, month, 1)
      the_day.beginning_of_day ... (the_day.end_of_month + 1).beginning_of_day
    end

    def cache_value
      self.count = config.countable.where(filter).where(created_at: time_range).count
    end

  end
end
