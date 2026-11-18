module Roled
  module Model::Menu
    extend ActiveSupport::Concern

    included do
      attribute :controller_path, :string
      attribute :action_name, :string, default: 'index'
      attribute :identifier, :string
      attribute :icon, :string
      attribute :position, :integer
      attribute :namespace, :string

      belongs_to :role, optional: true

      positioned on: [:role_id]

      before_validation :split_identifier, if: -> { identifier.present? && controller_path.blank? }
    end

    def real_path(**options)

    end

    def name
      I18n.t "#{[*controller_path.split('/'), action_name].join('.')}.title", default: nil
    end

    def split_identifier
      _controller, _action = identifier.split('#')
      self.controller_path = _controller
      self.action_name = _action
    end

  end
end
