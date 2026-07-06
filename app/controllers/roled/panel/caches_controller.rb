module Roled
  class Panel::CachesController < Panel::BaseController
    before_action :set_cache, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:id)

      @caches = Cache.where(q_params).order(id: :desc).page(params[:page])
    end

    private
    def set_cache
      @cach = Cache.find params[:id]
    end

    def set_filter_columns
      @filter_columns = set_filter_i18n(
        'id' => { type: 'string', default: true }
      )
    end

  end
end
