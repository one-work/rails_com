module Statis
  class Panel::CounterDaysController < Panel::BaseController
    before_action :set_config

    def index
      today = Date.today
      @counter_days = @config.counter_days.where(date: today.beginning_of_month ..).order(date: :desc)
      @counter_months = @config.counter_months.where(year: today.year, month: 1 .. today.month - 1).order(month: :desc)
      @counter_years = @config.counter_years.order(year: :desc)
    end

    private
    def set_config
      @config = Config.find(params[:config_id])
    end

  end
end
