module RailsCom
  module CacheHelper

    def cache_with_model(model, namespace = '')
      [model, namespace, current_member.cache, asset_path('icons_regular.svg')]
    end

  end
end
