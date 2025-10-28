module Com
  class Panel::LogsController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit('controller_name', 'action_name', 'path', 'ip')

      @logs = Log.default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def ip
      @logs = Log.select(:ip).group(:ip).order(count_com_logs_ip: :desc).count
    end

  end
end
