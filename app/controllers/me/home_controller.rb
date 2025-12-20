module Me
  class HomeController < BaseController
    skip_before_action :require_role, only: [:index] if whether_filter :require_role
    skip_before_action :require_org_member, only: [:index] if whether_filter :require_org_member
    before_action :require_member_or_user, only: [:index]

    def index
      set_roled_tabs
    end

    private
    def require_member_or_user
      return if current_member
      return if current_user
      require_user
    end

  end
end
