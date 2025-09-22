module RailsCom::ActiveRecord
  module Include
    extend ActiveSupport::Concern

    included do
      class_attribute :indexes_to_define_after_schema_loads, instance_accessor: false, default: []
    end

    def error_text
      errors.full_messages.join("\n")
    end

    def update_json_counter(column: 'counters', **cols)
      sql_str = cols.inject(column) do |sql, (col, num)|
        "jsonb_set(#{sql}, '{#{col}}', (COALESCE(counters->>'#{col}', '0')::numeric #{num.negative? ? '-' : '+'} #{num.abs})::text::jsonb, true)"
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

    def reset_attributes
      assign_attributes changes.transform_values(&->(i){ i[0] })
      self
    end

    def origin_attributes
      instance_variable_get(:@attributes).instance_variable_get(:@attributes)
    end

    def not_destroyed?
      !(destroyed? || marked_for_destruction?)
    end

    def base_class_name
      self.class.base_class.name
    end

    def pretty_print(pp)
      return super if custom_inspect_method_defined?
      pp.object_address_group(self) do
        if defined?(@attributes) && @attributes
          attr_names = self.class.attribute_names.select { |name| _has_attribute?(name) }
          max_indent = attr_names.map(&:length).max
          pp.seplist(attr_names, proc { pp.text ',' }) do |attr_name|
            pp.breakable "\n"
            pp.group(1) do
              pp.text attr_name.rjust(max_indent)
              pp.text ':'
              pp.breakable
              value = _read_attribute(attr_name)
              if value.is_a?(Array) && value.size > 3
                value = value[0..3]
                value[3] = '...'
              elsif value.is_a?(Hash)
                value = value.limit(3)
              end
              value = inspection_filter.filter_param(attr_name, value) unless value.nil?
              pp.pp value
            end
          end
        else
          pp.breakable ' '
          pp.text 'not initialized'
        end
      end
    end

    class_methods do
      def index(name, **options)
        h = { index: name, **options }
        self.indexes_to_define_after_schema_loads = self.indexes_to_define_after_schema_loads + [h]
      end
    end

  end
end

ActiveSupport.on_load :active_record do
  include RailsCom::ActiveRecord::Include
end
