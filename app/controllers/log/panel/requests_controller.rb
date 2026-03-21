module Log
  class Panel::RequestsController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit('controller_name', 'action_name', 'path', 'ip')
      if params.key? 'created_at-gte'
        q_params.merge! created_at: params['created_at-gte'].to_datetime..params['created_at-lte'].to_datetime
      end

      @requests = Request.where(q_params).order(id: :desc).page(params[:page]).per(params[:per])
    end

    def latest
      @request = Request.last
      render :show, locals: { model: @request }
    end

    def ip
      @requests = Request.select(:ip).group(:ip).order(count_com_logs_ip: :desc).count
    end

    private
    def set_filter_columns
      @filter_columns = set_filter_i18n(
        'path' => { type: 'search', default: true },
        'created_at' => { type: 'datetime', default: true }
      )
    end

  end
end
