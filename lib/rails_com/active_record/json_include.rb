module RailsCom::ActiveRecord
  module JsonInclude

    def update_json_counter(column: 'counters', **cols)
      sql_str = cols.inject(column) do |sql, (col, num)|
        if self.class.connection.adapter_name == 'PostgreSQL'
          "jsonb_set(#{sql}, '{#{col}}', (COALESCE(counters->>'#{col}', '0')::numeric #{num.negative? ? '-' : '+'} #{num.abs})::text::jsonb, true)"
        else
          "json_set(#{sql}, '$.#{col}', (COALESCE(json_extract(counters, '$.#{col}'), '0') #{num.negative? ? '-' : '+'} #{num.abs}))"
        end
      end

      self.class.where(id: id).update_all "#{column} = #{sql_str}"
    end

    def increment_json_counter(*cols, column: 'counters')
      to_cols = cols.each_with_object({}) do |col, h|
        h.merge! col => 1
      end
      update_json_counter(column: column, **to_cols)
    end

    def decrement_json_counter(*cols, column: 'counters')
      to_cols = cols.each_with_object({}) do |col, h|
        h.merge! col => -1
      end
      update_json_counter(column: column, **to_cols)
    end

  end
end

ActiveSupport.on_load :active_record do
  include RailsCom::ActiveRecord::JsonInclude
end