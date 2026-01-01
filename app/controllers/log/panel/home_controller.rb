module Log
  class Panel::HomeController < Panel::BaseController

    def index
      @data = SummaryDaily.select(:date, :duration_avg).as_json(only: ['date', 'duration_avg'])
    end

  end
end
