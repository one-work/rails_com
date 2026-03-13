module Statis
  module Ext::Counter
    extend ActiveSupport::Concern

    included do
      attribute :scope, :string
      attribute :cached, :boolean, default: false

      #has_many :counter_years, class_name: 'Statis::CounterYear', as: :counter, dependent: :delete_all
      #has_many :counter_months, class_name: 'Statis::CounterMonth', as: :counter, dependent: :delete_all
      #has_many :counter_days, class_name: 'Statis::CounterDay', as: :counter, dependent: :delete_all

      scope :to_cache, -> { where(cached: false) }

      after_create_commit :cache_from_config_later
    end

    def cache_from_config_later
      CounterJob.perform_later(self)
    end

    class_methods do

      def xx
        Config.where(statistical_type: self.base_class.name) || Config.create(statistical_type: self.base_class.name)
      end

    end

  end
end
