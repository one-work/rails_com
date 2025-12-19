module Statis
  class Panel::ConfigsController < Panel::BaseController

    private
    def config_params
      params.fetch(:config, {}).permit(
        :statistical_type,
        :note,
        :begin_on,
        :end_on,
        keys: [],
        scopes: []
      )
    end
  end
end
