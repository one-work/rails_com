module Meta
  class Panel::BusinessesController < Panel::BaseController

    def index
      @businesses = Business.with_attached_logo.order(position: :asc).page(params[:page])
    end

    def sync
      Business.sync
    end

    private
    def business_params
      params.fetch(:business, {}).permit(
        :name,
        :logo
      )
    end

  end
end
