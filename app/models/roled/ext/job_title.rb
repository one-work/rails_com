module Roled
  module Ext::JobTitle
    extend ActiveSupport::Concern

    included do
      include Ext::Base
    end

    def visible_roles
      Role.joins(:role_types).where(role_types: { who_type: 'Org::JobTitle' }).visible
    end

  end
end
