# frozen_string_literal: true

module RailsCom::ActiveRecord
  module ExtendTotal

    def total_threshold(threshold, column:, order: 'expire_at')
      with(running_total: self.select('id', column, order, Arel.sql("SUM(#{column}) OVER (ORDER BY #{order} DESC) AS total")))
        .from('running_total')
        .select('id', column, order)
        .where(total: threshold..)
    end

  end
end

ActiveSupport.on_load :active_record do
  extend RailsCom::ActiveRecord::ExtendTotal
end
