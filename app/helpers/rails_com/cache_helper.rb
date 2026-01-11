module RailsCom
  module CacheHelper

    def cache_with_model(namespace = '')
      ->(model) { [model, namespace, current_member.cache, compute_asset_path('icons_regular.svg')] }
    end

    def cache_with_svg(&block)
      cache([compute_asset_path('icons_regular.svg')], {}, &block)
    end

  end
end
