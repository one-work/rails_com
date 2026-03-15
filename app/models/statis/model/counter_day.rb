module Statis
  module Model::CounterDay
    extend ActiveSupport::Concern
    include Inner::Compute
    include Ext::Day

    included do
      belongs_to :counter_month, foreign_key: [:config_type, :config_id, :year_month], primary_key: [:config_type, :config_id, :year_month], optional: true
      belongs_to :counter_year, foreign_key: [:config_type, :config_id, :year], primary_key: [:config_type, :config_id, :year], optional: true
    end

  end
end
