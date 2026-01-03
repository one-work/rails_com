module Log
  class Panel::HomeController < Panel::BaseController

    def index
      yesterday = Date.yesterday

      @data = SummaryDaily.where(date: yesterday.prev_month..).select(:date, :duration_avg).order(date: :asc).as_json(only: ['date', 'duration_avg'])

      @request_dailies = RequestDaily.where(date: yesterday, total: 10..).order(duration_avg: :desc).limit(10)
      @query_dailies = QueryDaily.where(date: yesterday, total: 10..).order(duration_avg: :desc).limit(10)
    end

  end
end
