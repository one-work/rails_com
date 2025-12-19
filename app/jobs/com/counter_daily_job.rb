module Com
  class CounterDailyJob < ApplicationJob

    def perform
      Counter.find_each do |i|
        today = Date.today
        yesterday = today - 1

        if today == today.beginning_of_month
          i.cache_statistic_month(yesterday.to_fs(:year_and_month))
          i.counter_days.where(year: yesterday.year, month: yesterday.month).delete_all
        else
          i.cache_counter_day(yesterday)
        end
      end
    end

  end
end
