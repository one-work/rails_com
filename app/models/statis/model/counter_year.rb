module Statis
  module Model::CounterYear
    extend ActiveSupport::Concern
    include Inner::Compute
    include Ext::Year

    included do
      attribute :begin_on, :date

      has_many :counter_months, primary_key: [:config_type, :config_id, :year], foreign_key: [:config_type, :config_id, :year]

      after_create :clear_counter_months
    end

    def clear_counter_months
      counter_months.delete_all
    end

  end
end
