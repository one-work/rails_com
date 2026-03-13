# frozen_string_literal: true

module Statis
  module Inner::Compute
    extend ActiveSupport::Concern

    included do
      attribute :count, :integer
      attribute :values, :json, default: {}

      belongs_to :config, polymorphic: true, counter_cache: true
    end

    def cache_count
      self.count = config.filter_counter.where(created_at: time_range).count
    end

    def cache_values
      config.sum_columns.each do |column|
        self.values[column] = config.filter_counter.where(created_at: time_range).sum(column)
      end
    end

  end
end