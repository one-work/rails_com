module Com
  class Panel::CachesController < Panel::BaseController

    def index
      q_params = {}
      q_params.merge! params.permit(:key, :key_hash)

      @caches = SolidCache::Entry.where(q_params).page(params[:page])
    end

    private
    def set_cache
      @cache = SolidCache::Entry.find params[:id]
    end

    def model_klass
      SolidCache::Entry
    end

    def set_filter_columns
      @filter_columns = set_filter_i18n(
        'key' => { type: 'search', default: true },
        'key_hash' => { type: 'search', default: true },
        'created_at' => 'datetime'
      )
    end

  end
end
