module Meta
  class Panel::ControllersController < Panel::BaseController
    before_action :set_meta_controller, only: [:show, :edit, :update, :move_higher, :move_lower]

    def index
      q_params = {}
      q_params.merge! params.permit(:business_identifier, :namespace_identifier)

      @businesses = Business.order(position: :asc)
      @controllers = Controller.includes(:actions).default_where(q_params).page(params[:page])
    end

    def sync
      Controller.sync
    end

    def meta_namespaces
      @business = MetaBusiness.find_by identifier: params[:business_identifier]
      @namespaces = @business.meta_namespaces
    end

    def meta_controllers
      q_params = {}
      q_params.merge! params.permit(:business_identifier, :namespace_identifier)

      @controllers = Controller.includes(:actions).where(q_params)
    end

    def meta_actions
      @controller = Controller.find params[:meta_controller_id]
      @actions = @controller.actions
    end

    private
    def set_meta_controller
      @controller = Controller.find(params[:id])
    end

    def meta_controller_permit_params
      [
        :position
      ]
    end

  end
end
