module Statis
  module Model::CounterYear
    extend ActiveSupport::Concern

    included do
      attribute :year, :integer
      attribute :begin_on, :date
      attribute :count, :integer

      belongs_to :config, polymorphic: true, counter_cache: true
    end

    def time_range
      begin_on.beginning_of_day ... (begin_on.end_of_year + 1).beginning_of_day
    end


    time_range = the_day.beginning_of_day ... (the_day.end_of_year + 1).beginning_of_day


    def cache_value
      self.count = config.countable.where(created_at: time_range).count
    end

  end
end
