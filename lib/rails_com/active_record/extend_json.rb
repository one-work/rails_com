module RailsCom::ActiveRecord
  module ExtendJson

    def increment_json_counter(*cols, column: 'counters', num: 1)
      sql_str = cols.inject(column) do |sql, col|
        "jsonb_set(#{sql}, '{#{col}}', (COALESCE(counters->>'#{col}', '0')::int + #{num})::text::jsonb)"
      end

      update_all "#{column} = #{sql_str}"
    end

    def decrement_json_counter(*cols, column: 'counters', num: 1)
      sql_str = cols.inject(column) do |sql, col|
        "jsonb_set(counters, '{#{col}}', (COALESCE(counters->>'#{col}', '0')::int - #{num})::text::jsonb)"
      end

      update_all "#{column} = #{sql_str}"
    end

    def json_filter(column, **params)
      query = self

      params.each do |k, v|
        if v.is_a?(Array)
          or_string = []
          v.size.times { or_string << "#{column}->>'#{k}' = ?" }
          query = query.where([or_string.join(' OR '), *v])
        else
          query = query.where("#{column}->>'#{k}' = ?", v)
        end
      end

      query
    end

    def json_or(column, **params)
      query = self
      or_string = []
      or_v = []

      params.each do |k, v|
        or_string << "#{column}->>'#{k}' = ?"
        or_v << v
      end

      query.where([or_string.join(' OR '), *or_v])
    end

  end
end

ActiveSupport.on_load :active_record do
  extend RailsCom::ActiveRecord::ExtendJson
end
