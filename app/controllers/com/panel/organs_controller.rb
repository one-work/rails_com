module Com
  class Panel::OrgansController < Panel::BaseController
    before_action :set_organ

    private
    def set_organ
      @organ = current_organ
    end

    def organ_params
      params.fetch(:organ, {}).permit(
        theme_settings: {}
      )
    end

  end
end
