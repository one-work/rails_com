# frozen_string_literal: true

module Com
  module Ext::Countable
    extend ActiveSupport::Concern

    included do
      has_one :statistic_config, class_name: 'Com::StatisticConfig', primary_key: self.name, foreign_key: :statistical_type
      has_many :counters, class_name: 'Com::Counter', primary_key: self.name, foreign_key: :statistical_type
    end

    def today_begin_id
      where(created_at: ...Date.today.beginning_of_day.to_fs(:human)).order(id: :desc).first.id
    end

    def read_counter_count(extra: {})
      extras = extra.product_with_key
      all_counter = counters.where(extra: extras)

      CounterMonth.where(counter_id: all_counter.pluck(:id)).group_by(&:counter).inject(0) do |total, (counter, counter_months)|
        counter_months.each do |counter_month|
          total = total + counter_month.count
        end

        # 加上今天的实时数据
        today_value = today_count(counter)
        total + today_value
      end
    end

    def read_counter_year(extra: {}, year: Date.today.year)
      extras = extra.product_with_key
      all_counter = counters.where(extra: extras)

      CounterMonth.where(counter_id: all_counter.pluck(:id), year: year).group_by(&:counter).each_with_object({}) do |(counter, counter_months), count_h|
        counter_months.each do |counter_month|
          count_h[counter_month.year_month] = count_h[counter_month.year_month] + counter_month.count
        end

        # 加上今天的实时数据
        today_value = today_count(counter)
        count_h["#{Date.today.to_fs(:year_and_month)}"] = count_h["#{Date.today.to_fs(:year_and_month)}"] + today_value
      end
    end

    def generate_all_counters(extra_hash: {})
      extra_hash.product_with_key.each do |extra|
        counter = counters.find_or_initialize_by(extra: extra)
        counter.save
      end
    end

  end
end