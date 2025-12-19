module Com
  class Panel::ErrSummariesController < Panel::BaseController
    before_action :set_err_summary, only: [:show, :destroy, :clean]

    def index
      q_params = {}
      q_params.merge! params.permit('controller_name', 'action_name', 'exception_object', 'errs_count-desc')

      @err_summaries = ErrSummary.default_where(q_params).order(updated_at: :desc).page(params[:page]).per(params[:per])
    end

    def clean
      @err_summary.clean
    end

    private
    def set_err_summary
      @err_summary = ErrSummary.find(params[:id])
    end

  end
end
