module RailsCom::RoleHelper

  def role_permit_options?(options, method)
    return true if session.blank?  # 没有登录的情况下，默认放开所有权限

    if options.is_a? String
      begin
        path_params = Rails.application.routes.recognize_path options, { method: method }
      rescue ActionController::RoutingError
        return true  # 无法识别的路由（也就是没有在系统内定义）
      end
    elsif options == :back
      return true
    elsif options.is_a? Hash
      path_params = {
        controller: options[:controller] || controller_path,
        action: options[:action] || 'index'
      }
      Rails.application.routes.send :generate, nil, path_params, request.path_parameters  # 例如 'orders' -> 'trade/me/orders', 这里会直接改变 dup_params 的值
    else
      path_params = {
        controller: controller_path,
        action: 'index'
      }
    end

    possible_result = RailsCom::Routes.controllers.dig(path_params[:controller], path_params[:action]) || {}
    result_params = {
      business: possible_result[:business] || params[:business].to_s,
      namespace: possible_result[:namespace] || params[:namespace].to_s,
      controller: possible_result[:controller] || params[:controller],
      action: possible_result[:action] || params[:action]
    }

    result = role_permit?(**result_params)
    if Rails.configuration.x.role_debug || !result
      logger.debug "\e[35m  Options: #{options}  \e[0m"
    end
    result
  end

  def role_permit?(**path_params)
    meta_params = path_params.slice(:business, :namespace, :controller, :action).symbolize_keys
    extra_params = path_params.except(:controller, :action, :business, :namespace)
    if meta_params[:controller]
      filtered = meta_params[:controller].to_controller&.whether_filter_role(meta_params[:action])
    else
      filtered = true
    end

    if filtered && defined?(current_organ) && current_organ
      organ_permitted = current_organ.has_role?(params: extra_params, **meta_params)
    else
      organ_permitted = true
    end

    if filtered && defined?(rails_role_user) && rails_role_user
      user_permitted = rails_role_user.has_role?(params: extra_params, **meta_params)
    else
      user_permitted = true
    end

    result = organ_permitted && user_permitted
    if Rails.configuration.x.role_debug || !result
      logger.debug "\e[35m  Meta Params: #{meta_params}, Extra Params: #{extra_params}  \e[0m"
      logger.debug "\e[35m  #{current_organ&.base_class_name}_#{current_organ&.id}: #{organ_permitted.inspect}  \e[0m" if defined?(current_organ)
      logger.debug "\e[35m  #{rails_role_user&.base_class_name}_#{rails_role_user&.id}: #{user_permitted.inspect}  \e[0m"
    end

    result
  end

end
