module RailsCom::ActiveRecord
  module Extend

    def human_name
      model_name.human
    end

    def reset_pk_sequence!
      connection.reset_pk_sequence!(table_name)
    end

    def subclasses_tree(tree = {}, node = self)
      tree[node] ||= {}

      node.subclasses.each do |subclass|
        tree[node].merge! subclasses_tree(tree[node], subclass)
      end

      tree
    end

    def remove_duplicates_by(field)
      select(field).group(field).having('COUNT(*) > 1').pluck(field).each do |value|
        records = where(field => value).order(:id)
        records.offset(1).destroy_all
      end
    end

    def to_fixture
      require 'rails/generators/test_unit/model/model_generator'

      args = [
        self.name.underscore
      ]
      cols = columns.reject(&->(i){ attributes_by_default.include?(i.name) }).map { |col| "#{col.name}:#{col.type}" }

      generator = TestUnit::Generators::ModelGenerator.new(args + cols, destination_root: Rails.root, fixture: true)
      generator.instance_variable_set :@source_paths, Array(RailsCom::Engine.root.join('lib/templates', 'test_unit/model'))
      generator.invoke_all
    end

    def com_column_names
      column_names - attributes_by_default + attachment_reflections.select(&->(_, i){ i.macro == :has_one_attached }).keys
    end

    def com_column_hash
      attaches = attachment_reflections.select(&->(_, i){ i.macro == :has_many_attached })
      attaches.transform_values!(&->(_){ [] })
    end

    def com_column_extra
      extra = columns.select { |i| i.type == :json }
      extra.each_with_object({}) do |i, h|
        h.merge! i.name => {}
      end
    end

    def column_attributes
      columns.map do |column|
        r = {
          name: column.name.to_sym,
          type: column.type
        }
        r.merge! null: column.null unless column.null
        r.merge! default: column.default unless column.default.nil?
        r.merge! comment: column.comment if column.comment.present?
        r.merge! column.sql_type_metadata.instance_values.slice('limit', 'precision', 'scale').compact
        r.symbolize_keys!
      end
    end

    def pending_attributes
      r = {}

      send(:pending_attribute_modifications).each do |attr|
        if attr.instance_of? ActiveModel::AttributeRegistration::ClassMethods::PendingDefault
          r[attr.name] ||= {}
          r[attr.name][:default] = attr
        elsif attr.instance_of? ActiveModel::AttributeRegistration::ClassMethods::PendingType
          r[attr.name] ||= {}
          r[attr.name][:type] = attr
        elsif attr.instance_of? ActiveModel::AttributeRegistration::ClassMethods::PendingDecorator
          name = attr.names[0]
          r[name] ||= {}
          r[name][:type] = ActiveModel::Type::String.new
        end
      end

      r
    end

    def attributes_by_model
      cols = {}

      pending_attributes.each do |name, column|
        r = {}
        r.merge! original_type: column[:type].type

        if r[:original_type].respond_to?(:type)
          r.merge! raw_type: r[:original_type].type
        end

        case r[:original_type].class.name
        when 'ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array'
          r.merge! array: true
        when 'ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Range'
          r.merge! range: true
        end

        if r[:original_type].respond_to?(:options) && r[:original_type].options.present?
          r.merge! r[:original_type].options
        end

        if column[:default]
          r.merge! default: column[:default].default
        end

        cols.merge! name => r
      end

      cols
    end

    def migrate_attributes_by_model
      cols = {}
      attributes_by_model.each do |name, column|
        r = {}
        r.merge! column
        r.symbolize_keys!
        r.merge! migrate_type: column[:raw_type]

        if r[:original_type].respond_to? :migrate_type
          r.merge! migrate_type: r[:original_type].migrate_type
        end

        if r[:virtual]
          r.merge! migrate_type: :virtual, type: r[:migrate_type], stored: true
        end

        if r[:default].respond_to?(:call)
          r.delete(:default)
        end

        if r[:array] && connection.adapter_name != 'PostgreSQL'
          r.delete(:array)
          r[:migrate_type] = :json
          r.delete(:default) if r[:default].is_a? Array
        end

        if r[:migrate_type] == :json
          if connection.adapter_name == 'PostgreSQL' # Postgres 替换 json 为 jsonb
            r[:migrate_type] = :jsonb
          else
            r.delete(:default) # mysql 数据库不能接受 json 的默认值
          end
        end

        if r[:migrate_type] == :jsonb && connection.adapter_name != 'PostgreSQL'
          r[:migrate_type] == :json
          r.delete(:default)
        end

        # 这里不同步 default 这个选项，这样可以监测 changes
        r.merge! attribute_options: r.slice(:limit, :precision, :scale, :null, :index, :array, :range, :size, :comment, :type, :as, :stored).inject('') { |s, h| s << ", #{h[0]}: #{h[1].inspect}" }

        cols.merge! name.to_sym => r
      end

      cols
    end

    def migrate_attributes_by_db
      return {} unless table_exists?
      cols = {}

      columns_hash.each do |name, column|
        r = { original_type: column.type }
        r.merge! migrate_type: r[:original_type]
        r.merge! null: column.null unless column.null
        r.merge! default: column.default unless column.default.nil?
        r.merge! comment: column.comment if column.comment.present?
        r.merge! column.sql_type_metadata.instance_values.slice('limit', 'precision', 'scale').compact
        r.symbolize_keys!
        r.merge! attribute_options: r.slice(:limit, :precision, :scale, :null, :index, :array, :size, :default, :comment, :stored).inject('') { |s, h| s << ", #{h[0]}: #{h[1].inspect}" }

        cols.merge! name.to_sym => r
      end

      cols
    end

    def attributes_by_default
      if table_exists?
        if primary_key.is_a? Array
          primary_key.map(&:to_sym) + all_timestamp_attributes_in_model.map(&:to_sym)
        else
          [primary_key.to_sym] + all_timestamp_attributes_in_model.map(&:to_sym)
        end
      else
        []
      end
    end

    def attributes_by_belongs
      results = {}

      reflections_with_belongs_to.each do |_, reflection|
        next if reflection.foreign_key.is_a? Array
        results.merge! reflection.foreign_key.to_sym => {
          input_type: :integer  # todo 考虑 foreign_key 不是自增 ID 的场景
        }
        results.merge! reflection.foreign_type.to_sym => { input_type: :string } if reflection.foreign_type
      end
      results.except! *attributes_by_model.keys.map(&:to_s)

      results
    end

    def references_by_model
      results = {}
      refs = reflections_with_belongs_to
      refs.reject! { |_, reflection| reflection.foreign_key.to_s != "#{reflection.name}_id" }
      refs.reject! { |_, reflection| pending_attributes.key?(reflection.foreign_key) }
      refs.each do |_, ref|
        r = { name: ref.name }
        if ref.polymorphic?
          r.merge! polymorphic: true
        end
        if connection.adapter_name == 'PostgreSQL'
          r.merge! type: :uuid
        end
        r.merge! reference_options: r.slice(:polymorphic, :type).inject('') { |s, h| s << ", #{h[0]}: #{h[1].inspect}" }
        results[ref.foreign_key.to_sym] = r unless results.key?(ref.foreign_key.to_sym)
      end

      results
    end

    def indexes_by_model
      indexes = indexes_to_define_after_schema_loads
      indexes.map! do |index|
        index.merge! index_options: index.slice(:unique, :name).inject('') { |s, h| s << ", #{h[0]}: #{h[1].inspect}" }
      end
    end

    def indexes_by_db
      connection.indexes table_name
    end

    def rename_index(old_name, new_name)
      connection.rename_index(table_name, old_name, new_name)
    end

    def reflections_with_belongs_to
      reflections.select { |_, reflection| reflection.belongs_to? }
    end

    def reflections_with_collection
      reflections.values.select(&->(reflection){ reflection.collection? })
    end

    def reflections_with_primary_keys
      reflections_with_collection.map(&:active_record_primary_key).flatten.uniq
    end

  end
end

ActiveSupport.on_load :active_record do
  extend RailsCom::ActiveRecord::Extend
end
