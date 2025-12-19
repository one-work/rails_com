module Roled
  module Controller::Panel

    def rails_role_user
      return @rails_role_user if defined? @rails_role_user
      if defined?(current_user) && current_user
        @rails_role_user = current_user
      else
        @rails_role_user = current_member
      end
      logger.debug "\e[35m  Panel Role User: #{@rails_role_user&.base_class_name}/#{@rails_role_user&.id}  \e[0m"
      @rails_role_user
    end

  end
end
