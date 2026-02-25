# frozen_string_literal: true

module RailsCom::ActiveRecord
  module ExtendTotal

    def total_threshold(threshold, column: 'amount', order: 'expire_at')
      with(running_total: self.select('id', column, order, Arel.sql("SUM(#{column}) OVER (ORDER BY #{order} ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total")))
        .from('running_total')
        .select('id', column, order, 'total')
      .unscope(:where).where(Arel.sql("total < :threshold + #{column}"), threshold: threshold)
    end

  end
end

ActiveSupport.on_load :active_record do
  extend RailsCom::ActiveRecord::ExtendTotal
end
