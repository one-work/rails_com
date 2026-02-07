module Roled
  class Panel::RolesController < Panel::BaseController
    before_action :set_role, only: [
      :show, :overview, :edit, :update, :destroy,
      :namespaces, :controllers, :actions,
      :business_on, :business_off, :namespace_on, :namespace_off, :controller_on, :controller_off, :action_on, :action_off
    ]
    before_action :set_new_role, only: [:new, :create]

    def index
      @roles = Role.order(id: :asc).page(params[:page])
    end

    def show
      q_params = {}

      @controllers = Meta::Controller.includes(:actions).default_where(q_params)
      @businesses = Meta::Business.all
      render :show, locals: { model: @role }
    end

    def namespaces
      @business = Meta::Business.find_by identifier: params[:business_identifier]
    end

    def controllers
      @namespace = Meta::Namespace.find_by identifier: params[:namespace_identifier]
      @controllers = Meta::Controller.includes(:actions).where(params.permit(:business_identifier, :namespace_identifier))
    end

    def actions
      @controller = Meta::Controller.find params[:meta_controller_id]
      @actions = @controller.meta_actions
    end

    def overview
      @taxon_ids = @role.meta_controllers.unscope(:order).uniq
    end

    def business_on
      @business = Meta::Business.find_by identifier: params[:business_identifier]
      @role.business_on @business
      @role.save

      render :namespaces
    end

    def business_off
      @business = Meta::Business.find_by identifier: params[:business_identifier]
      @role.business_off(business_identifier: @business.identifier)
      @role.save

      render :namespaces
    end

    def namespace_on
      @namespace = Meta::Namespace.find_by identifier: params[:namespace_identifier]
      @role.namespace_on(@namespace, params[:business_identifier])
      @role.save

      @controllers = Meta::Controller.where(params.permit(:business_identifier, :namespace_identifier))
      @business = Meta::Business.find_by identifier: params[:business_identifier]
      render :controllers_toggle
    end

    def namespace_off
      @namespace = Meta::Namespace.find_by identifier: params[:namespace_identifier]
      @role.namespace_off(namespace_identifier: @namespace.identifier, business_identifier: params[:business_identifier])
      @role.save

      @controllers = Meta::Controller.where(params.permit(:business_identifier, :namespace_identifier))
      @business = Meta::Business.find_by identifier: params[:business_identifier]

      render :controllers_toggle
    end

    def controller_on
      @controller = Meta::Controller.find params[:meta_controller_id]
      @role.controller_on(@controller)
      @role.save

      render :actions_toggle
    end

    def controller_off
      @controller = Meta::Controller.find params[:meta_controller_id]
      @role.controller_off(**@controller.role_list)
      @role.save

      render :actions_toggle
    end

    def action_on
      @action = Meta::Action.find params[:meta_action_id]
      @role.action_on(@action)
      @role.save

      render :action
    end

    def action_off
      @action = Meta::Action.find params[:meta_action_id]
      @role.action_off(@action)
      @role.save

      render :action
    end

    private
    def role_params
      params.fetch(:role, {}).permit(
        :name,
        :tip,
        :code,
        :description,
        :visible,
        :default,
        role_types_attributes: [:who_type, :id, :_destroy]
      )
    end

    def set_role
      @role = Role.find params[:id]
    end

    def set_new_role
      @role = Role.new role_params
    end

  end
end
