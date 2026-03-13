# frozen_string_literal: true

module Statis
  module Inner::Compute
    extend ActiveSupport::Concern

    def cache_count
      self.count = config.countable.where(created_at: time_range).count
    end

    def cache_values
      config.sum_columns.each do |column|
        self.values[column] = config.countable.where(created_at: time_range).sum(column)
      end
    end

  end
end