module Statis
  module Ext::Config
    extend ActiveSupport::Concern

    included do
      attribute :begin_on, :date
      attribute :end_on, :date
      attribute :note, :string
      attribute :sums, :json, default: []
      attribute :today, :date
      attribute :today_begin_id, :big_integer
      attribute :counter_years_count, :integer
      attribute :counter_months_count, :integer
      attribute :counter_days_count, :integer

      has_many :counter_days, as: :config
      has_many :counter_months, as: :config
      has_many :counter_years, as: :config

      before_save :compute_time_range
    end

    def compute_time_range

    end

    def filter_counter
      self.class.countable.where(filter)
    end

    def filter
      attributes.slice(self.class.scopes)
    end

    def compute_today_begin!
      id = countable.where(created_at: ...Date.today.beginning_of_day.to_fs(:human)).order(id: :desc).first.id
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
          cache_counter_year(begin_on.year, the_day)
        end
        cache_months(Date.new(end_on.year, 1, 1), end_on)
      elsif begin_on.year == end_on.year  # 当开始的时间范围和结束的时间范围在同一年
        cache_months(begin_on, end_on)
      end
    end

    def cache_months(begin_on, end_on)
      if begin_on.month < end_on.month
        (begin_on.month .. (end_on.month - 1)).each do |month|
          cache_counter_month(begin_on.year, month)
        end
        cache_days(Date.new(end_on.year, end_on.month, 1), end_on)
      elsif begin_on.month == begin_on.month
        cache_days(begin_on, end_on)
      end
    end

    def cache_days(begin_on, end_on)
      #return if end_on.day == 1 # 如果当天是月初第一天则没必要缓存计算
      #(today.beginning_of_month .. (today - 1))

      (begin_on .. end_on).each do |date|
        cache_counter_day(date)
      end
    end

    def cache_counter_year(year, the_day)
      time_range = the_day.beginning_of_day ... (the_day.end_of_year + 1).beginning_of_day

      arr.each do |k|
        counter_year = counter_years.build(year: year)
        counter_year.begin_on = the_start
        counter_year.cache_value
        counter_year.save
      end
    end

    def cache_counter_month(year, month)
      the_day = Date.new(year, month, 1)
      time_range  = the_day.beginning_of_day ... (the_day.end_of_month + 1).beginning_of_day


      arr.each do |k|
        counter_month = counter_months.build(year: year, month: month)
        counter_month.cache_value
        counter_month.save
      end
    end

    def cache_counter_day(date = begin_on)
      time_range  = date.beginning_of_day ... (date + 1).beginning_of_day

      counter_days.where(date: date).delete_all
      arr.each do |k|
        counter_day = counter_days.build(date: date)
        counter_day.cache_value
        counter_day.save
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
          self.create scopes.zip(k).to_h
        end
      end

    end

  end
end
