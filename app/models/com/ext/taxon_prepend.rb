module Com
  module Ext::TaxonPrepend
    extend ActiveSupport::Concern

    included do
      if table_exists? && column_names.include?('children_count')
        belongs_to(
          :parent, nil,
          class_name: _ct.model_class.to_s,
          foreign_key: _ct.parent_column_name,
          inverse_of: :children,
          touch: _ct.options[:touch],
          counter_cache: :children_count,
          optional: true
        )
      end
    end

    def self_and_siblings
      if self.class.column_names.include?('organ_id')
        super.where(organ_id: self.organ_id)
      else
        super
      end
    end

    def depth
      if parent
        parent.depth + 1
      else
        super
      end
    end

  end
end
