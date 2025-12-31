module Log
  class Panel::QueriesController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit('name')

      @queries = Query.default_where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

  end
end
