module Com
  module Model::MetaController
    extend ActiveSupport::Concern

    included do
      attribute :namespace_identifier, :string, default: '', null: false, index: true
      attribute :business_identifier, :string, default: '', null: false, index: true
      attribute :controller_path, :string, null: false, index: true
      attribute :controller_name, :string, null: false
      attribute :synced_at, :datetime
      attribute :position, :integer

      belongs_to :meta_namespace, foreign_key: :namespace_identifier, primary_key: :identifier, optional: true
      belongs_to :meta_business, foreign_key: :business_identifier, primary_key: :identifier, optional: true

      has_many(
        :meta_actions,
        foreign_key: :controller_path,
        primary_key: :controller_path,
        dependent: :destroy_async,
        inverse_of: :meta_controller
      )
      accepts_nested_attributes_for :meta_actions, allow_destroy: true

      scope :ordered, -> { order(position: :asc, id: :asc) }

      validates :controller_path, uniqueness: { scope: [:business_identifier, :namespace_identifier] }

      positioned on: [:namespace_identifier, :business_identifier]
    end

    def identifier
      [business_identifier, namespace_identifier, (controller_path.blank? ? '_' : controller_path)].join('_')
    end

    def business_name
      t = I18n.t "#{business_identifier}.title", default: nil
      return t if t

      business_identifier
    end

    def namespace_name
      t = I18n.t "#{business_identifier}.#{namespace_identifier}.title", default: nil
      return t if t

      namespace_identifier
    end

    def name
      t = I18n.t "#{controller_path.to_s.split('/').join('.')}.index.title", default: nil
      return t if t

      controller_path
    end

    def role_path
      {
        business_identifier.to_s => {
          namespace_identifier.to_s => { controller_path => role_hash }
        }
      }
    end

    def role_list
      {
        business_identifier: business_identifier.to_s,
        namespace_identifier: namespace_identifier.to_s,
        controller_path: controller_path
      }
    end

    def role_hash
      meta_actions.each_with_object({}) { |i, h| h.merge! i.action_name => i.role_hash }
    end

    class_methods do

      def actions
        result = {}
        MetaBusiness.all.includes(meta_controllers: :meta_actions).each do |meta_business|
          result.merge! meta_business.identifier => meta_business.meta_controllers.group_by(&:namespace_identifier).transform_values!(&->(meta_controllers){
            meta_controllers.each_with_object({}) { |meta_controller, h| h.merge! meta_controller.controller_name => meta_controller.meta_actions.pluck(:action_name) }
          })
        end
        result
      end

      def sync
        Com::MetaBusiness.all.each { |i| i.sync_all }
      end

    end

  end
end
