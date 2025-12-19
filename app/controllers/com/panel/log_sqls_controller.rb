module Com
  class Panel::LogSqlsController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit('name')

      @log_sqls = LogSql.default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

  end
end
