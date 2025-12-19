module Statis
  module Model::StatisticYear
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
      attribute :value, :decimal

      belongs_to :statistic, counter_cache: true
    end

  end
end
