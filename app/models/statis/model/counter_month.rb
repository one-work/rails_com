module Statis
  module Model::CounterMonth
    extend ActiveSupport::Concern
    include Ext::Month

    included do
      attribute :count, :integer
      attribute :filter, :json

      belongs_to :config, counter_cache: true
      belongs_to :counter_year, foreign_key: [:config_id, :year], primary_key: [:config_id, :year], optional: true
    end

    def cache_value
      self.count = config.countable.where(filter).where(created_at: time_range).count
    end

  end
end
