module Log
  class Panel::HomeController < Panel::BaseController

    def index
      @data = SummaryDaily.where(date: Date.today.prev_month..).select(:date, :duration_avg).order(date: :asc).as_json(only: ['date', 'duration_avg'])
    end

  end
end
