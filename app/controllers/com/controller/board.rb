module Com
  module Controller::Board
    extend ActiveSupport::Concern
    include Controller::Curd

    def set_roled_tabs
      if defined?(current_member) && current_member
        @roled_tabs = current_member.tabs.where(namespace: 'admin').load.sort_by(&:position)
      else
        super
      end
      logger.debug "\e[35m  Board SetRoleTabs: #{@roled_tabs}  \e[0m" if RailsCom.config.debug
    end

  end
end
