module Com
  module Controller::Admin
    extend ActiveSupport::Concern
    include Controller::Curd

    included do
      skip_before_action :require_user if whether_filter :require_user
    end

    private
    def set_locale
      super
    end

    def set_timezone
      super
    end

    def set_roled_tabs
      if defined?(current_member) && current_member
        @roled_tabs = current_member.tabs.where(namespace: 'admin').load.sort_by(&:position)
      else
        @roled_tabs = Roled::Tab.none
      end
      logger.debug "\e[35m  Admin SetRoleTabs: #{@roled_tabs}  \e[0m" if RailsCom.config.debug
    end

  end
end
