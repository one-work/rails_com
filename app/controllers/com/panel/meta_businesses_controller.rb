module Com
  class Panel::MetaBusinessesController < Panel::BaseController

    def index
      @meta_businesses = MetaBusiness.with_attached_logo.order(position: :asc).page(params[:page])
    end

    def sync
      MetaBusiness.sync
    end

    private
    def meta_business_permit_params
      [
        :name,
        :logo
      ]
    end

  end
end
