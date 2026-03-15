module Statis
  module Model::CounterMonth
    extend ActiveSupport::Concern
    include Inner::Compute
    include Ext::Month

    included do
      belongs_to :counter_year, foreign_key: [:config_type, :config_id, :year], primary_key: [:config_type, :config_id, :year], optional: true
    end

  end
end
