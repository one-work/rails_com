module Roled
  class Panel::RoleWhosController < Panel::BaseController
    before_action :set_role
    before_action :set_who_role, only: [:destroy]

    def index
      @role_whos = @role.role_whos.page(params[:page])
    end

    def destroy
      @who_role.destroy
    end

    private
    def set_role
      @role = Role.find params[:role_id]
    end

    def set_who_role
      @who_role = WhoRole.find(params[:id])
    end

    def who_role_params
      params.fetch(:who_role, {}).permit(
        :who_id,
        :created_at
      )
    end

  end
end
