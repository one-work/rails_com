module Statis
  module Ext::Config
    extend ActiveSupport::Concern

    included do
      attribute :begin_on, :date
      attribute :end_on, :date
      attribute :note, :string
      attribute :count, :integer
      attribute :values, :json, default: []
      attribute :today, :date
      attribute :today_begin_id, :big_integer
      attribute :counter_years_count, :integer
      attribute :counter_months_count, :integer
      attribute :counter_days_count, :integer

      has_many :counter_days, class_name: 'Statis::CounterDay', as: :config, dependent: :delete_all
      has_many :counter_months, class_name: 'Statis::CounterMonth', as: :config, dependent: :delete_all
      has_many :counter_years, class_name: 'Statis::CounterYear', as: :config, dependent: :delete_all

      before_save :compute_time_range
    end

    def compute_time_range
      first = filter_counter.order(created_at: :asc).first
      self.begin_on = first.created_at.to_date

      last = filter_counter.order(created_at: :desc).first
      self.end_on = last.created_at.to_date
    end

    def filter_counter
      self.class.countable.where(filter)
    end

    def filter
      attributes.slice(self.class.scopes)
    end

    def sum_columns
      []
    end

    def compute_today_begin!
      id = filter_counter.where(created_at: ...Date.today.beginning_of_day.to_fs(:human)).order(id: :desc).first.id
      self.today_begin_id = id
      self.today = Date.today
      self.save
    end

    def compute_counters
      if begin_on.year < end_on.year
        (begin_on.year .. (end_on.year - 1)).each_with_index do |year, index|
          if index == 0
            the_day = begin_on
          else
            the_day = Date.new(year, 1, 1)
          end
          counter_year = counter_years.find_or_initialize_by(year: year)
          counter_year.begin_on = the_day
          counter_year.save
        end
        cache_months(Date.new(end_on.year, 1, 1), end_on)
      elsif begin_on.year == end_on.year  # 当开始的时间范围和结束的时间范围在同一年
        cache_months(begin_on, end_on)
      end
    end

    def cache_months(begin_on, end_on)
      if begin_on.month < end_on.month
        (begin_on.month .. (end_on.month - 1)).each do |month|
          counter_months.find_or_create_by(year: year, month: month)
        end
        cache_days(Date.new(end_on.year, end_on.month, 1), end_on)
      elsif begin_on.month == end_on.month
        #return if end_on.day == 1 # 如果当天是月初第一天则没必要缓存计算
        #(today.beginning_of_month .. (today - 1))
        cache_days(begin_on, end_on)
      end
    end

    def cache_days(begin_on, end_on)
      (begin_on .. end_on).each do |date|
        counter_days.find_or_create_by(date: date)
      end
    end

    class_methods do

      def countable
        self.name.delete_suffix('CounterCache').constantize
      end

      def scopes
        column_names - [
          'id',
          'organ_id',
          'begin_on',
          'end_on',
          'note',
          'sums',
          'today',
          'today_begin_id',
          'counter_years_count',
          'counter_months_count',
          'counter_days_count',
          'created_at',
          'updated_at'
        ]
      end

      def init_records
        arr = countable.select(scopes).distinct.pluck(scopes)
        arr.each do |k|
          self.find_or_create_by scopes.zip(k).to_h
        end
      end

    end

  end
end
