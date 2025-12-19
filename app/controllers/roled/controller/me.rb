module Roled
  module Controller::Me

    def rails_role_user
      logger.debug "\e[35m  Role User: Member  \e[0m"
      current_member
    end

  end
end
