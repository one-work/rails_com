module Me
  class HomeController < BaseController
    skip_before_action :require_role, only: [:index, :douyin] if whether_filter :require_role
    skip_before_action :require_org_member, only: [:index, :douyin] if whether_filter :require_org_member
    skip_before_action :require_user, only: [:douyin] if whether_filter :require_user
    before_action :require_member_or_user, only: [:index]
    layout 'me/home'

    def index
      set_roled_tabs
      set_roled_menus
    end

    def douyin
      set_roled_menus
    end

    private
    def require_member_or_user
      return if defined?(current_member) && current_member
      if current_user
        choose_only_member
        return
      end
      require_user
    end

  end
end
