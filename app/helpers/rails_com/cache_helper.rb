module RailsCom
  module CacheHelper

    def cache_with_model(namespace = '')
      ->(model) do
        [
          model,
          namespace,
          current_member.cache,
          compute_asset_path('icons_regular.svg'),
          compute_asset_host('icons_regular.svg')
        ]
      end
    end

    def cache_with_organ(namespace = '')
      ->(model) do
        [
          model,
          namespace,
          current_member.cache,
          current_member.organ,
          compute_asset_path('icons_regular.svg')
        ]
      end
    end

  end
end
