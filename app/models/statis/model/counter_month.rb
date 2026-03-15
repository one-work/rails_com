module Statis
  module Model::CounterMonth
    extend ActiveSupport::Concern
    include Inner::Compute
    include Ext::Month

    included do
      belongs_to :counter_year, foreign_key: [:config_type, :config_id, :year], primary_key: [:config_type, :config_id, :year], optional: true

      has_many :counter_days, primary_key: [:config_type, :config_id, :year_month], foreign_key: [:config_type, :config_id, :year_month]

      after_create :clear_counter_days
    end

    def clear_counter_days
      counter_days.delete_all
    end

  end
end
