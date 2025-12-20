module RailsCom::Models
  extend self

  def models_hash(root = ActiveRecord::Base)
    return @models_hash if defined? @models_hash
    Zeitwerk::Loader.eager_load_all
    @models_hash = root.subclasses_tree
  end

  def models(root = ActiveRecord::Base)
    return @models if defined? @models
    Zeitwerk::Loader.eager_load_all
    @models = root.descendants
    @models.reject!(&:abstract_class?)
    @models
  end

  def reset_pk_sequence!
    models.map do |i|
      i.reset_pk_sequence!
    end
  end

  def db_tables_hash
    migrate_tables_hash.group_by { |_, v| v[:migrations_paths] }.transform_values!(&:to_h)
  end

  def tables_hash(root = ActiveRecord::Base, records_hash = models_hash)
    @tables ||= {}

    records_hash[root].each_key do |node|
      next if RailsCom.config.ignore_models.include?(node.to_s)

      unless node.abstract_class?
        @tables[node.table_name] ||= {}
        r = @tables[node.table_name]
        r[:models] ||= []
        r[:models] << node unless r[:models].include?(node)

        r[:table_exists] = r[:table_exists] || node.table_exists?

        r[:model_attributes] ||= {}
        r[:model_attributes].reverse_merge! node.migrate_attributes_by_model

        r[:model_references] ||= {}
        r[:model_references].reverse_merge! node.references_by_model

        r[:indexes] ||= []
        r[:indexes] |= node.indexes_by_model

        r[:model_defaults] ||= []
        r[:model_defaults] |= node.attributes_by_default

        r[:belongs_attributes] ||= {}
        r[:belongs_attributes].reverse_merge! node.attributes_by_belongs

        if node.primary_key.is_a? Array
          table_options = { id: false }
        else
          if r[:model_attributes][node.primary_key.to_sym]
            table_options = {
              id: r[:model_attributes].delete(node.primary_key.to_sym)[:migrate_type]
            }
            if table_options[:id] == :uuid
              table_options.merge! default: 'uuidv7()'
            end
          elsif node.connection.adapter_name == 'PostgreSQL'
            table_options = {
              id: :uuid,
              default: 'uuidv7()'
            }
          else
            table_options = {}
          end
        end

        r[:table_options] = table_options.inject('') { |s, h| s << ", #{h[0]}: #{h[1].inspect}" }
      end

      tables_hash(node, records_hash[root])
    end

    @tables
  end

  def migrate_tables_hash
    tables = {}

    tables_hash.each do |table_name, cols|
      model = cols[:models][0]
      db = model.migrate_attributes_by_db

      r = cols.slice(:indexes, :table_exists, :table_options)
      r[:migrations_paths] = model.connection_pool.migrations_paths
      r[:add_attributes] = cols[:model_attributes].except *db.keys
      r[:add_references] = cols[:model_references].except *db.keys
      r[:timestamps] = [:created_at, :updated_at] & r[:add_attributes].keys
      r[:remove_attributes] = db.except(*cols[:model_attributes].keys, *cols[:belongs_attributes].keys, *cols[:model_defaults])

      unless r[:add_attributes].blank? && r[:add_references].blank? && r[:remove_attributes].blank?
        tables[table_name.to_sym] = r
      end
    end

    tables
  end

  def unbound_tables
    ActiveRecord::Base.connection.tables - models.map(&:table_name) - ['schema_migrations', 'ar_internal_metadata']
  end

  def migrate_modules_hash
    tables = ActiveRecord::Base.connection.tables
    @modules = {}

    models.group_by(&:module_parent).each do |module_name, record_classes|
      new_prefix = (module_name.respond_to?(:table_name_prefix) && module_name.table_name_prefix) || ''
      old_prefix = (module_name.respond_to?(:old_table_name_prefix) && module_name.old_table_name_prefix) || ''

      record_classes.each do |record_class|
        unless record_class.table_exists?
          possible = record_class.table_name.sub(/^#{new_prefix}/, old_prefix)
          @modules.merge! record_class.table_name => possible if tables.any?(possible)
        end
      end
    end

    arr = @modules.values
    result = arr.find_all { |e| arr.rindex(e) != arr.index(e) }
    warn "Please check #{result}"

    @modules
  end

  def ignore_models
    models.group_by(&->(i){ i.pending_attributes.size }).transform_values!(&->(i) { i.map(&:to_s) })
  end

  def attachments
    @attachments = {}
    models.each do |model|
      attaches = model.attachment_reflections.transform_values(&:macro)
      @attachments.merge! model.name => attaches if attaches.present?
    end

    @attachments
  end

  def ignore_tables
    [
      'schema_migrations',
      'ar_internal_metadata'
    ]
  end

  def model_names
    models.map(&:to_s)
  end

end
