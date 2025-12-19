module Com
  class Panel::MetaActionsController < Panel::BaseController
    before_action :set_meta_controller
    before_action :set_meta_action, only: [:show, :roles, :edit, :update, :move_higher, :move_lower, :destroy]

    def index
      @meta_actions = @meta_controller.meta_actions.order(position: :asc, id: :asc)
    end

    def new
      @meta_action = @meta_controller.meta_actions.build
    end

    def create
      @meta_action = @meta_controller.meta_actions.build(meta_action_params)

      unless @meta_action.save
        render :new, locals: { model: @meta_action }, status: :unprocessable_entity
      end
    end

    def roles
      @roles = @meta_action.roles
    end

    private
    def set_meta_controller
      @meta_controller = MetaController.find params[:meta_controller_id]
    end

    def set_meta_action
      @meta_action = @meta_controller.meta_actions.find(params[:id])
    end

    def meta_action_permit_params
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
