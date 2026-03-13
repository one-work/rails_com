module Statis
  module Model::CounterYear
    extend ActiveSupport::Concern
    include Inner::Compute

    included do
      attribute :year, :integer
      attribute :begin_on, :date
    end

    def time_range
      begin_on.beginning_of_day ... (begin_on.end_of_year + 1).beginning_of_day
    end

  end
end
