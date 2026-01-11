module Meta
  module Model::Action
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
      attribute :action_name, :string, null: false
      attribute :identifier, :string
      attribute :path, :string
      attribute :verb, :string
      attribute :position, :integer
      attribute :landmark, :boolean
      attribute :synced_at, :datetime
      attribute :testable, :boolean
      attribute :request_as, :string, default: 'turbo_stream'
      if connection.adapter_name == 'PostgreSQL'
        attribute :required_parts, :string, array: true
      else
        attribute :required_parts, :json
      end

      enum :operation, {
        list: 'list',
        read: 'read',
        add: 'add',
        edit: 'edit',
        remove: 'remove'
      }, default: 'read'

      belongs_to :business, foreign_key: :business_identifier, primary_key: :identifier
      belongs_to :namespace, foreign_key: :namespace_identifier, primary_key: :identifier
      belongs_to :controller, foreign_key: :controller_path, primary_key: :controller_path

      scope :admin_list, ->(business){ where(required_parts: [], action_name: 'index', business_identifier: business, namespace_identifier: 'admin') }
      scope :testable, -> { where(testable: true) }

      positioned on: [:business_identifier, :namespace_identifier, :controller_path]

      before_validation :set_identifier, if: -> { (changes.keys & ['controller_path', 'action_name']).present? }
      before_validation :sync_from_controller, if: -> { controller && (controller_path_changed? || controller.new_record?) }
      before_validation :sync_from_action, if: -> { action_name_changed? }
      before_validation :set_testable
      before_validation :set_request_as, if: -> { namespace_identifier_changed? }
    end

    def sync_from_action
      ope = if MAPPINGS.key? action_name
        MAPPINGS[action_name]
      elsif ['POST'].include? verb
        'add'
      else
        'read'
      end

      self.operation = ope
    end

    def set_testable
      self.testable = true if controller.test_klass
    end

    def set_request_as
      if namespace_identifier == 'api'
        self.request_as = 'json'
      end
    end

    def model_path
      "#{business_identifier}/#{controller_name}"
    end

    def model_klass
      model_path.classify.safe_constantize
    end

    def path_without_format
      path.delete_suffix('(.:format)')
    end

    def test_run
      return unless Rails.env.test?

      if controller.test_klass.instance_methods.include? :"test_#{action_name}_ok"
        test_instance = controller.test_klass.new("test_#{action_name}_ok", self)
      else
        test_instance = controller.test_klass.new("test_#{operation}_ok", self)
      end
      test_instance.run
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

    def set_identifier
      self.identifier = "#{controller_path}##{action_name}"
    end

    def name
      t1 = I18n.t "#{[business_identifier, namespace_identifier, controller_name, action_name].join('.')}.title", default: nil
      return t1 if t1

      t2 = self.class.enum_i18n :action_name, self.action_name
      return t2 if t2

      identifier
    end

    def sync_from_controller
      self.business_identifier = controller.business_identifier
      self.namespace_identifier = controller.namespace_identifier
    end

    class_methods do

      def sync
        Business.sync
        Namespace.sync
        Controller.sync
      end

    end

  end
end
