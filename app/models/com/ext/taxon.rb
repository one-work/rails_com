# required fields
# :parent_id
require 'closure_tree'
module Com
  module Ext::Taxon

    def self.included(model)
      if model.table_exists? && model.column_names.include?('position')
        model.has_closure_tree order: 'position'
      else
        model.has_closure_tree order: 'id'
      end
      model.include Com::Ext::TaxonPrepend

      model.attribute :parent_ancestors, :json, default: {}
      model.before_validation :sync_parent_id, if: -> { parent_ancestors_changed? && (parent_ancestors.presence != parent_ancestors_was.presence) }
      model.before_validation :set_parent_ancestors, if: -> { parent.present? && parent_ancestors.blank? }  # todo 考虑 parent 改变的情况
      model.hierarchy_class.attribute :generations, :integer, null: false
      model.hierarchy_class.attribute :created_at, :datetime, null: true  # 需要 created_at/updated_at 可为空值
      model.hierarchy_class.attribute :updated_at, :datetime, null: true
      model.hierarchy_class.index [:ancestor_id, :descendant_id, :generations], unique: true, name: "#{model.name.underscore}_anc_desc_idx"

      hierarchy_model = ['Model', model.hierarchy_class.name.split('::')[-1]].join('::')
      if model.module_parent.const_defined? hierarchy_model
        model.hierarchy_class.include model.module_parent.const_get(hierarchy_model)
      end

      def model.max_depth
        self.hierarchy_class.maximum(:generations).to_i + 1
      end

      def model.extract_multi_attributes(pairs)
        _pairs = pairs.select { |k, _| k.include?('(') }
        _real = {}
        r = self.new.send :extract_callstack_for_multiparameter_attributes, _pairs
        r.each do |k, v|
          _real[k.sub(/ancestors$/, 'id')] = v.values.compact.last
        end
        _real
      end
    end

    def depth_str
      (0..self.class.max_depth - self.depth).to_a.reverse.join
    end

    def set_parent_ancestors
      self.parent_ancestors = Hash(parent.parent_ancestors).merge! parent.depth.to_s => parent.id
    end

    def sync_parent_id
      _parent_id = Hash(parent_ancestors).values.compact.last
      if _parent_id
        self.parent_id = _parent_id
      else
        self.parent_id = nil
      end
    end

    def middle?
      parent_id.present? && depth < self.class.max_depth
    end

    def sheer_descendant_ids(c_ids = child_ids)
      @sheer_descendant_ids ||= c_ids.dup
      get_ids = self.class.where(parent_id: c_ids).pluck(:id)
      if get_ids.present?
        _get_ids = get_ids - @sheer_descendant_ids
        @sheer_descendant_ids.concat get_ids
        sheer_descendant_ids(_get_ids)
      else
        @sheer_descendant_ids
      end
    end

    def sheer_ancestor_ids
      node, node_ids = self, []
      until (node_ids + [self.id]).include?(node.parent_id)
        node_ids << node.parent_id
        node = node.parent
      end
      node_ids
    end

  end
end
