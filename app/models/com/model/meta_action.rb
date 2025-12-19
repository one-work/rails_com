module Com
  module Model::MetaAction
    extend ActiveSupport::Concern
    MAPPINGS = {
      'index' => 'list',
      'new' => 'add',
      'create' => 'add',
      'show' => 'read',
      'edit' => 'edit',
      'update' => 'edit',
      'destroy' => 'remove'
    }

    included do
      attribute :namespace_identifier, :string, default: '', null: false, index: true
      attribute :business_identifier, :string, default: '', null: false, index: true
      attribute :controller_path, :string, null: false, index: true
      attribute :controller_name, :string, null: false
      attribute :action_name, :string
      attribute :path, :string
      attribute :verb, :string
      attribute :position, :integer
      attribute :landmark, :boolean
      attribute :synced_at, :datetime
      if connection.adapter_name == 'PostgreSQL'
        attribute :required_parts, :string, array: true
      else
        attribute :required_parts, :json
      end

      belongs_to :meta_business, foreign_key: :business_identifier, primary_key: :identifier
      belongs_to :meta_namespace, foreign_key: :namespace_identifier, primary_key: :identifier
      belongs_to :meta_controller, foreign_key: :controller_path, primary_key: :controller_path

      enum :operation, {
        list: 'list',
        read: 'read',
        add: 'add',
        edit: 'edit',
        remove: 'remove'
      }, default: 'read'

      scope :admin_list, ->(business){ where(required_parts: [], action_name: 'index', business_identifier: business, namespace_identifier: 'admin') }

      positioned on: [:business_identifier, :namespace_identifier, :controller_path]

      before_validation :sync_from_controller, if: -> { meta_controller && (controller_path_changed? || meta_controller.new_record?) }
      before_validation :sync_from_action, if: -> { action_name_changed? }
    end

    def sync_from_action
      self.operation = MAPPINGS[action_name]
    end

    def role_path
      {
        business_identifier => {
          namespace_identifier => {
            controller_path => {
              action_name => role_hash
            }
          }
        }
      }
    end

    def role_list
      {
        business_identifier: business_identifier.to_s,
        namespace_identifier: namespace_identifier.to_s,
        controller_path: controller_path,
        action_name: action_name
      }
    end

    def role_hash
      id
    end

    def identifier
      [business_identifier, namespace_identifier, controller_path, (action_name.blank? ? '_' : action_name)].join('_')
    end

    def name
      t1 = I18n.t "#{[business_identifier, namespace_identifier, controller_name, action_name].join('.')}.title", default: nil
      return t1 if t1

      t2 = self.class.enum_i18n :action_name, self.action_name
      return t2 if t2

      identifier
    end

    def sync_from_controller
      self.business_identifier = meta_controller.business_identifier
      self.namespace_identifier = meta_controller.namespace_identifier
    end

  end
end
