module Meta
  module Model::Business
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :identifier, :string, default: '', null: false, index: true
      attribute :position, :integer
      attribute :synced_at, :datetime

      has_many :controllers, foreign_key: :business_identifier, primary_key: :identifier
      has_many :actions, foreign_key: :business_identifier, primary_key: :identifier
      has_many(
        :admin_actions,
        ->{ where(required_parts: [], action_name: 'index', namespace_identifier: 'admin') },
        foreign_key: :business_identifier,
        primary_key: :identifier,
        class_name: 'Action'
      )

      has_one_attached :logo

      validates :identifier, uniqueness: true

      positioned
    end

    def name
      return super if super.present?

      t = I18n.t "#{identifier}.title", default: nil
      return t if t

      identifier
    end

    def tr_id
      "tr_#{identifier.blank? ? '_' : identifier}"
    end

    def meta_namespaces
      Namespace.where(identifier: controllers.select(:namespace_identifier).distinct.pluck(:namespace_identifier))
    end

    def role_path
      {
        identifier => role_hash
      }
    end

    def role_hash
      meta_namespaces.each_with_object({}) { |i, h| h.merge! i.identifier => i.role_hash(identifier) }
    end

    def namespaces
      RailsCom::Routes.actions
    end

    def sync_all(now: Time.current)
      if RailsCom::Routes.actions.key? identifier
        sync(now: now)
      else
        self.prune
        self.destroy
      end
    end

    def sync(now: Time.current)
      RailsCom::Routes.actions[identifier].each do |namespace, _controllers|
        collected_controllers = _controllers.map do |controller, actions|
          meta_controller = controllers.find { |i| i.controller_path == controller } || controllers.build(controller_path: controller)
          meta_controller.namespace_identifier = namespace
          meta_controller.controller_name = controller.to_s.split('/')[-1]
          meta_controller.synced_at = now

          collected_actions = actions.map do |action_name, action|
            meta_action = meta_controller.actions.find { |i| i.action_name == action_name } || meta_controller.actions.build(action_name: action_name)
            meta_action.controller_name = meta_controller.controller_name
            meta_action.path = action[:path]
            meta_action.verb = action[:verb]
            meta_action.required_parts = action[:required_parts]
            meta_action.synced_at = now
            meta_action
          end
          self.class.transaction do
            collected_actions.each { |i| i.save! }
          end

          meta_controller
        end

        self.class.transaction do
          collected_controllers.each { |i| i.save! }
        end
      end
      self.update! synced_at: now
      prune
    end

    def prune
      controllers.where.not(synced_at: synced_at).or(controllers.where(synced_at: nil)).delete_all
      actions.where.not(synced_at: synced_at).or(actions.where(synced_at: nil)).delete_all
    end

    def svg_icon
      self.class.icon_mappings[identifier] || 'face-smile'
    end

    class_methods do

      def sync
        existing = self.select(:identifier).distinct.pluck(:identifier)
        business_keys = RailsCom::Routes.businesses.keys

        (business_keys - existing).each do |business|
          b = self.find_or_initialize_by(identifier: business)
          b.save
        end

        (existing - business_keys).each do |business|
          self.find_by(identifier: business).destroy
        end
      end

      def icon_mappings
        return @icon_mappings if defined? @icon_mappings

        icon_path = RailsCom::Engine.root.join('config/icons_business.yml')
        @icon_mappings = YAML.safe_load_file(icon_path)
      end

    end

  end
end
