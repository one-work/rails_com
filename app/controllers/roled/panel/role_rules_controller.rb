module Roled
  class Panel::RoleRulesController < Panel::BaseController
    before_action :set_role
    before_action :set_role_rule, only: [:show, :edit, :update]
    before_action :set_new_role_rule, only: [:new, :create]

    def index
      @role_rules = @role.role_rules.page(params[:page])
    end

    def disable
    end

    def destroy
      q_params = {
        namespace_identifier: nil,
        controller_identifier: nil,
        action_name: nil
      }
      q_params.merge! params.permit(:business_identifier, :namespace_identifier, :controller_identifier, :action_name)

      @role_rules = RoleRule.where(q_params)
      @role_rules.each(&:destroy)
    end

    private
    def set_role
      @role = Role.find params[:role_id]
    end

    def set_role_rule
      @role_rule = @role.role_rules.find params[:id]
    end

    def set_new_role_rule
      @role_rule = @role.role_rules.build(role_rule_params)
    end

    def role_rule_params
      params.permit(
        :business_identifier,
        :namespace_identifier,
        :controller_identifier,
        :action_name,
        :params_name,
        :params_identifier
      )
    end

  end
end
