module Log
  class QueryDailyJob < ApplicationJob

    def perform(today = Date.yesterday)
      Query.where(created_at: today.beginning_of_day ... today.next_day.beginning_of_day).select(:name).distinct.pluck(:name).each do |identifier|
        QueryDaily.find_or_create_by(date: today, identifier: identifier)
      end
    end

  end
end
