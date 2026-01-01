module Log
  class Panel::HomeController < Panel::BaseController

    def index
      @data = SummaryDaily.where(date: Date.today.prev_month..).select(:date, :duration_avg).order(date: :asc).as_json(only: ['date', 'duration_avg'])

      @request_dailies = RequestDaily.where(date: Date.today.prev_day).order(duration_avg: :desc).limit(10)
    end

  end
end
