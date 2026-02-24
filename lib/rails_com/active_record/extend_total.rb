# frozen_string_literal: true

module RailsCom::ActiveRecord
  module ExtendTotal

    def total_threshold(threshold, column:, order: 'expire_at')
      with(running_total: self.select(:id, column, Arel.sql("SUM(#{column}) OVER (ORDER BY #{order} DESC) AS total")))
        .from(:running_total)
        .where(Arel.sql("total <= :threshold OR (total > :threshold AND total - #{column} < :threshold)"), threshold: threshold)
        .order(column => :desc)
    end

  end
end

ActiveSupport.on_load :active_record do
  extend RailsCom::ActiveRecord::ExtendTotal
end
