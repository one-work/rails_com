module Roled
  module Ext::Organ
    extend ActiveSupport::Concern
    include Ext::Base

    included do
      attribute :admin, :boolean, default: false

      after_create :inherit_provider_roles, if: -> { provider.present? }
    end

    def inherit_provider_roles
      self.roles = provider.mock_roles
    end

  end
end
