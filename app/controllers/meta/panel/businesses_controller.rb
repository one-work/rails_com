module Meta
  class Panel::BusinessesController < Panel::BaseController

    def index
      @businesses = Business.with_attached_logo.order(position: :asc).page(params[:page])
    end

    def sync
      Business.sync
    end

    private
    def business_permit_params
      [
        :name,
        :logo
      ]
    end

  end
end
