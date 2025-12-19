module Statis
  class Panel::StatisticsController < Panel::BaseController
    before_action :set_statistic, only: [:show, :destroy]
    #before_action :set_statistical

    def index
      q_params = {}
      q_params.merge! params.permit(:column)

      @statistics = @statistical.statistics.default_where(q_params).order(created_at: :desc).page(params[:page]).per(params[:per])
    end

    def statistical
      @statistics = Statistic.select(:statistical_type, :statistical_id).distinct.page(params[:page])
    end

    def months
      @month_counts = StatisticMonth.group(:year_month).order(year_month: :desc).count(:statistic_id)
    end

    def month
      q_params = {}
      q_params.merge! params.permit(:column)
      @statistics = Statistic.joins(:statistic_months).where(statistic_months: { year_month: params[:month] }).default_where(q_params).page(params[:page])
    end

    def do_cache
      @statistical.statistical_month_job(params[:month])
    end

    private
    def set_statistic
      @statistic = Statistic.find(params[:id])
    end

    def set_statistical
      @statistical = params[:statistical_type].constantize.find params[:statistical_id]
    end

  end
end
