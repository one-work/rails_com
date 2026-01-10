module Log
  class Panel::HomeController < Panel::BaseController

    def index
      yesterday = Date.yesterday
      @data = SummaryDaily.where(date: yesterday.prev_month..).select(:date, :duration_avg).order(date: :asc).as_json(only: ['date', 'duration_avg'])

      @request_dailies = RequestDaily.where(date: yesterday).order(duration_avg: :desc)
      request_min = @request_dailies.limit(10).minimum(:total)
      @request_dailies = @request_dailies.where(total: request_min..).limit(10)

      @query_dailies = QueryDaily.where(date: yesterday).order(duration_avg: :desc)
      query_min = @query_dailies.limit(10).minimum(:total)
      @query_dailies = @query_dailies.where(total: query_min..).limit(10)
    end

  end
end
