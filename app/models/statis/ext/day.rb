module Statis
  module Ext::Day
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
      attribute :month, :integer
      attribute :day, :integer
      attribute :date, :date
      attribute :year_month, :string, index: true
    end

  end
end
