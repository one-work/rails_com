module Meta
  module Model::Controller
    extend ActiveSupport::Concern

    included do
      attribute :namespace_identifier, :string, default: '', null: false, index: true
      attribute :business_identifier, :string, default: '', null: false, index: true
      attribute :controller_path, :string, null: false, index: true
      attribute :controller_name, :string, null: false
      attribute :synced_at, :datetime
      attribute :position, :integer

      belongs_to :namespace, foreign_key: :namespace_identifier, primary_key: :identifier, optional: true
      belongs_to :business, foreign_key: :business_identifier, primary_key: :identifier, optional: true

      has_many(
        :actions,
        foreign_key: :controller_path,
        primary_key: :controller_path,
        dependent: :destroy_async,
        inverse_of: :controller
      )
      accepts_nested_attributes_for :actions, allow_destroy: true

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

    def test_klass
      "#{controller_path.camelize}ControllerTest".safe_constantize
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
      actions.each_with_object({}) { |i, h| h.merge! i.action_name => i.role_hash }
    end

    class_methods do

      def actions
        result = {}
        Business.all.includes(controllers: :actions).each do |business|
          result.merge! business.identifier => business.controllers.group_by(&:namespace_identifier).transform_values!(&->(controllers){
            controllers.each_with_object({}) { |controller, h| h.merge! controller.controller_name => controller.actions.pluck(:action_name) }
          })
        end
        result
      end

      def sync
        Business.all.each { |i| i.sync_all }
      end

    end

  end
end
