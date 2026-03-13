module Statis
  module Model::CounterMonth
    extend ActiveSupport::Concern
    include Inner::Compute

    included do
      attribute :year, :integer
      attribute :month, :integer
      attribute :year_month, :string, index: true

      belongs_to :counter_year, foreign_key: [:config_type, :config_id, :year], primary_key: [:config_type, :config_id, :year], optional: true

      after_initialize :init_year_month, if: :new_record?
    end

    def init_year_month
      self.year_month = "#{year}-#{month.to_s.rjust(2, '0')}"
    end

    def time_range
      the_day = Date.new(year, month, 1)
      the_day.beginning_of_day ... (the_day.end_of_month + 1).beginning_of_day
    end

  end
end
