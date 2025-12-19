module Com
  class Panel::ErrsController < Panel::BaseController
    before_action :set_err_summary
    before_action :set_err, only: [:show, :destroy, :clean_other]

    def index
      q_params = {}
      q_params.merge! params.permit('controller_name', 'action_name', 'path-like', 'exception_object')

      @errs = @err_summary.errs.default_where(q_params).page(params[:page]).per(params[:per])
    end

    def clean_other
      @err.clean_other
    end

    private
    def set_err_summary
      @err_summary = ErrSummary.find params[:err_summary_id]
    end

    def set_err
      @err = @err_summary.errs.find(params[:id])
    end

  end
end
