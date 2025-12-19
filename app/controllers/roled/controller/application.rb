module Roled
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :rails_role_user
    end

    private
    def support_organ
      if current_organ.has_role?(
        business: params[:business] || 'application',
        namespace: params[:namespace] || 'application',
        controller: controller_name,
        action: action_name,
        params: params
      )
        return
      elsif current_organ.nil?
        return
      elsif request.path == RailsCom.config.default_return_path
        return
      end

      role_denied
    end

    def require_role
      if rails_role_user && rails_role_user.has_role?(
        business: params[:business],
        namespace: params[:namespace],
        controller: controller_path,
        action: action_name,
        params: params
      )
        return
      end

      role_denied
    end

    def rails_role_user
      return @rails_role_user if defined? @rails_role_user
      @rails_role_user = defined?(current_user) && current_user
      logger.debug "\e[35m  Role User: #{@rails_role_user&.base_class_name}/#{@rails_role_user&.id}  \e[0m"
      @rails_role_user
    end

    def role_denied
      respond_to do |format|
        format.turbo_stream { render 'role_denied', layout: 'raw' }
        format.html { render 'role_denied' }
      end
    end

  end
end
