module Log
  class RequestDailyJob < ApplicationJob

    def perform(today = Date.yesterday)
      Request.where(duration: 300..).select(:identifier).distinct.pluck(:identifier).each do |identifier|
        RequestDaily.find_or_create_by(date: today, identifier: identifier)
      end

      SummaryDaily.find_or_create_by(date: today)
    end

  end
end
