# frozen_string_literal: true

module Statis
  module Inner::Compute
    extend ActiveSupport::Concern

    included do
      attribute :count, :integer
      attribute :values, :json, default: {}
      attribute :version, :string, default: '1'

      belongs_to :config, polymorphic: true, counter_cache: true

      before_save :cache_count, if: -> { version_changed? }
      before_save :cache_values, if: -> { version_changed? }
    end

    def cache_count
      self.count = config.filter_counter.where(created_at: time_range).count
    end

    def cache_values
      config.sum_columns.each do |column, proc|
        if proc.respond_to? :call
          self.values[column] = proc.call(config.filter_counter.where(created_at: time_range))
        else
          self.values[column] = config.filter_counter.where(created_at: time_range).sum(column)
        end
      end
    end

  end
end