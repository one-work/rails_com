module Roled
  module Ext::Organ
    extend ActiveSupport::Concern
    include Ext::Base

    included do
      attribute :admin, :boolean, default: false
    end

  end
end
