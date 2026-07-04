module Roled
  class Panel::CachesController < Panel::BaseController
    before_action :set_cache, only: [:show, :edit, :update]

    def index
      @caches = Cache.order(id: :desc).page(params[:page])
    end

    private
    def set_cache
      @cache = Cache.find params[:id]
    end

  end
end
