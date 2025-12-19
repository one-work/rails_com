module Com
  class Panel::CspsController < Panel::BaseController
    before_action :set_csp, only: [:show, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:document_uri)

      @csps = Csp.default_where(q_params).page(params[:page])
    end

    private
    def set_csp
      @csp = Csp.find(params[:id])
    end

  end
end
