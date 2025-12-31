module Log
  class RequestDailyJob < ApplicationJob

    def perform(today = Date.yesterday)
      Request.where(duration: 300..).select(:identifier).distinct.pluck(:identifier).each do |identifier|
        RequestDaily.create(date: today, identifier: identifier)
      end

      SummaryDaily.create(date: today)
    end

  end
end
