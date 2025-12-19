module Roled
  class Panel::TabsController < Panel::BaseController
    before_action :set_role
    before_action :set_tab, only: [:show, :edit, :update]
    before_action :set_new_tab, only: [:new, :create]

    def index
      @tabs = @role.tabs.order(position: :asc).page(params[:page])
    end

    private
    def set_role
      @role = Role.find params[:role_id]
    end

    def set_tab
      @tab = @role.tabs.find params[:id]
    end

    def set_new_tab
      @tab = @role.tabs.build(tab_params)
    end

    def tab_params
      params.fetch(:tab, {}).permit(
        :path,
        :icon,
        :name,
        :namespace
      )
    end

  end
end
