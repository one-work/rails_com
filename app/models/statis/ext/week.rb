module Statis
  module Ext::Week
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
      attribute :cweek, :integer
      attribute :start_at, :datetime
      attribute :finish_at, :datetime
    end

  end
end
