module Com
  module Model::MetaModel
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :record_name, :string, index: true
      attribute :table_name, :string
      attribute :description, :string
      attribute :defined_db, :boolean, default: false
      attribute :customizable, :boolean, default: false, comment: '是否允许用户定制'
      attribute :business_identifier, :string, default: '', null: false, index: true

      has_many :meta_columns, foreign_key: :record_name, primary_key: :record_name, inverse_of: :meta_model

      before_validation :sync_business_identifier, if: -> { record_name_changed? }
    end

    def record_class
      return @record_class if defined? @record_class
      @record_class = record_name.constantize
    end

    def sync_business_identifier
      self.business_identifier = record_name.split('::')[-2].to_s.downcase
      self.table_name = record_class.table_name
    end

    def display_name
      name.presence || record_name
    end

    class_methods do

      def sync
        RailsCom::Models.models.each do |model|
          next unless model.table_exists?
          meta_model = self.find_or_initialize_by(record_name: model.name)
          meta_model.defined_db = true

          model.columns.each do |column|
            meta_column = meta_model.meta_columns.find_or_initialize_by(column_name: column.name)
            meta_column.column_type = column.type
            meta_column.sql_type = column.sql_type
            meta_column.column_limit = column.limit
            meta_column.comment = column.comment
            meta_column.defined_db = true
            meta_column.defined_model = true if model.pending_attributes.keys.include?(column.name)

            present_meta_columns = meta_model.meta_columns.pluck(:column_name)
            meta_model.meta_columns.select(&->(i){ (present_meta_columns - model.column_names).include?(i.column_name) }).each do |needless_column|
              needless_column.mark_for_destruction
            end
          end
          meta_model.save if meta_model.meta_columns.length > 0

          present_models = self.pluck(:record_name)
          self.where(record_name: (present_models - RailsCom::Models.model_names)).each do |needless_model|
            needless_model.destroy
          end
        end
      end

      # todo 导出为 json 配置
      def dump

      end

    end

  end
end
