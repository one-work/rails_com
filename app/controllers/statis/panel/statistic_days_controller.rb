module Statis
  class Panel::StatisticDaysController < Panel::BaseController
    before_action :set_statistic

    def index
      today = Date.today
      @statistic_days = @statistic.statistic_days.where(date: Date.today.beginning_of_month..).order(date: :desc)
      if @statistic.statistic_config
        @statistic_months = @statistic.statistic_months.where(year: @statistic.statistic_config.begin_on.year..).order(year_month: :desc)
      else
        @statistic_months = @statistic.statistic_months.where(year: today.year, month: 1..today.month - 1).order(year_month: :desc)
      end
      @statistic_years = @statistic.statistic_years.order(year: :desc)
    end

    private
    def set_statistic
      @statistic = Statistic.find(params[:statistic_id])
    end

  end
end
