module Com
  module Model::MetaColumn
    extend ActiveSupport::Concern

    included do
      attribute :record_name, :string, index: true
      attribute :column_name, :string
      attribute :sql_type, :string
      attribute :column_type, :string
      attribute :column_limit, :integer
      attribute :comment, :string
      attribute :defined_db, :boolean, default: false
      attribute :defined_model, :boolean, default: false
      attribute :belongs_enable, :boolean, default: false
      attribute :belongs_table, :string

      belongs_to :meta_model, foreign_key: :record_name, primary_key: :record_name
    end

    def sync
      unless record_class.column_names.include?(self.column_name)
        record_class.connection.add_column(record_class.table_name, column_name, column_type)
        record_class.reset_column_information
      end
    end

    def i18n_name
      record_class.human_attribute_name(column_name)
    end

    def belongs_model
      record_class.reflections_with_belongs_to[column_name.delete_suffix('_id')].klass
    end

    def filter_type
      if record_class.reflections_with_belongs_to.map { |_, i| i.foreign_key }.include? column_name
        'filter_input_belongs'
      else
        "filter_input_#{column_type}"
      end
    end

    def remove
      record_class.connection.remove_column(record_class.table_name, column_name, if_exists: true)
    end

    def test
      record_class.update self.column_name => 'ss'
    end

    def record_class
      record_name.constantize
    end

  end
end
