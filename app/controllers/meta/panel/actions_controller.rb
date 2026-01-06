module Meta
  class Panel::ActionsController < Panel::BaseController
    before_action :set_controller
    before_action :set_action, only: [:show, :roles, :edit, :update, :move_higher, :move_lower, :destroy]

    def index
      @actions = @controller.actions.order(position: :asc, id: :asc)
    end

    def roles
      @roles = @action.roles
    end

    private
    def set_controller
      @controller = MetaController.find params[:controller_id]
    end

    def set_action
      @action = @controller.actions.find(params[:id])
    end

    def action_permit_params
      [
        :operation,
        :name,
        :params,
        :position,
        :landmark
      ]
    end

  end
end
