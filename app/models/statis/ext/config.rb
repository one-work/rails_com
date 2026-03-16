module Statis
  module Ext::Config
    extend ActiveSupport::Concern

    included do
      attribute :begin_on, :date
      attribute :end_on, :date
      attribute :note, :string
      attribute :count, :integer
      attribute :values, :json, default: {}
      attribute :today, :date
      attribute :today_begin_id, :uuid
      attribute :version, :string
      attribute :counter_years_count, :integer
      attribute :counter_months_count, :integer
      attribute :counter_days_count, :integer

      has_many :counter_days, class_name: 'Statis::CounterDay', as: :config, dependent: :delete_all
      has_many :counter_months, class_name: 'Statis::CounterMonth', as: :config, dependent: :delete_all
      has_many :counter_years, class_name: 'Statis::CounterYear', as: :config, dependent: :delete_all

      before_create :compute_time_range
      before_create :compute_today_begin
      after_save_commit :recompute!, if: -> { saved_change_to_version? }
    end

    def get_today_count
      if today_begin_id
        r = {
          count: count + self.class.countable.where('id > ?', today_begin_id).count
        }
        sum_columns.each do |col|
          r.merge! col.to_sym => values[col].to_d + self.class.countable.where('id > ?', today_begin_id).sum(col)
        end
        r
      else
        r = { count: 0 }
        sum_columns.each { |col| r.merge! col.to_sym => 0 }
        r
      end
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
      attributes.slice(*self.class.scopes).compact
    end

    def sum_columns
      []
    end

    def compute_today_begin(today = Date.today)
      id = filter_counter.where(created_at: ...today.beginning_of_day.to_fs(:human)).order(id: :desc).first.id
      self.today_begin_id = id
      self.today = today
      self
    end

    def compute_today_begin!
      compute_today_begin
      save
    end

    def compute!
      compute_counters
      sum_counters!
    end

    def recompute!
      counter_years.update(version: version)
      counter_years.update(version: version)
      counter_years.update(version: version)
      sum_counters!
    end

    def sum_counters!
      self.count = counter_years.sum(:count) + counter_months.sum(:count) + counter_days.sum(:count)
      sum_columns.each do |col|
        self.values[col] = (counter_years.json_sum(col) + counter_months.json_sum(col) + counter_days.json_sum(col)).round(2)
      end
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
          counter_year.version = version
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
          counter_month = counter_months.find_or_initialize_by(year: end_on.year, month: month)
          counter_month.version = version
          counter_month.save
        end
        cache_days(Date.new(end_on.year, end_on.month, 1), end_on)
      elsif begin_on.month == end_on.month
        cache_days(begin_on, end_on)
      end
    end

    def cache_days(begin_on, end_on)
      # 没必要缓存计算
      # 当天是月初第一天
      # 开始日期和结束日期同一天
      (begin_on .. end_on).each do |date|
        counter_day = counter_days.find_or_initialize_by(date: date)
        counter_day.version = version
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
          'count',
          'values',
          'today',
          'today_begin_id',
          'version',
          'counter_years_count',
          'counter_months_count',
          'counter_days_count',
          'created_at',
          'updated_at'
        ]
      end

      def find_by_params(params)
        filter = scopes.each_with_object({}) { |k, h| h.merge! k => nil }
        filter.merge! params.slice(*scopes)
        find_or_initialize_by filter
      end

      def init_records
        if scopes.present?
          arr = countable.select(scopes).distinct.pluck(scopes)
          arr.each do |k|
            self.find_or_create_by scopes.zip(k).to_h
          end

          scopes.each do |scope|
            countable.select(scope).distinct.pluck(scope).each do |k|
              self.find_or_create_by scope => k, **(scopes - [scope]).each_with_object({}) { |i, h| h.merge! i => nil }
            end
          end
        end

        self.find_or_create_by scopes.each_with_object({}) { |i, h| h.merge! i => nil }
      end

    end

  end
end
