module Log
  class Panel::RequestDailiesController < Panel::BaseController

    def index
      yesterday = Date.yesterday
      @request_dailies = RequestDaily.where(date: yesterday).order(duration_avg: :desc).page(params[:page])
    end

  end
end
