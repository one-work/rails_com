module Statis
  module Model::Config
    extend ActiveSupport::Concern

    included do
      attribute :statistical_type, :string
      attribute :begin_on, :date
      attribute :end_on, :date
      attribute :note, :string
      attribute :scopes, :json, default: []
      attribute :keys, :json, default: []
      attribute :sums, :json, default: []
      attribute :today, :date
      attribute :today_begin_id, :big_integer
      attribute :counter_years_count, :integer
      attribute :counter_months_count, :integer
      attribute :counter_days_count, :integer

      has_many :counter_days
      has_many :counter_months
      has_many :counter_years
    end

    def compute_today_begin!
      id = countable.where(created_at: ...Date.today.beginning_of_day.to_fs(:human)).order(id: :desc).first.id
      self.today_begin_id = id
      self.today = Date.today
      self.save
    end

    def countable
      statistical_type.constantize
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
      arr = countable.where(created_at: time_range).select(scopes).distinct.pluck(scopes)

      arr.each do |k|
        counter_year = counter_years.build(year: year)
        counter_year.filter = scopes.zip(k).to_h
        counter_year.begin_on = the_start
        counter_year.cache_value
        counter_year.save
      end
    end

    def cache_counter_month(year, month)
      the_day = Date.new(year, month, 1)
      time_range  = the_day.beginning_of_day ... (the_day.end_of_month + 1).beginning_of_day
      arr = countable.where(created_at: time_range).select(scopes).distinct.pluck(scopes)

      arr.each do |k|
        counter_month = counter_months.build(year: year, month: month)
        counter_month.filter = scopes.zip(k).to_h
        counter_month.cache_value
        counter_month.save
      end
    end

    def cache_counter_day(date = begin_on)
      time_range  = date.beginning_of_day ... (date + 1).beginning_of_day
      arr = countable.where(created_at: time_range).select(scopes).distinct.pluck(scopes)

      counter_days.where(date: date).delete_all
      arr.each do |k|
        counter_day = counter_days.build(date: date)
        counter_day.filter = scopes.zip(k).to_h
        counter_day.cache_value
        counter_day.save
      end
    end

  end
end
