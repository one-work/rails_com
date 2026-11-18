module Me
  class HomeController < BaseController
    skip_before_action :require_role, only: [:index] if whether_filter :require_role
    skip_before_action :require_org_member, only: [:index] if whether_filter :require_org_member
    before_action :require_member_or_user, only: [:index]
    layout 'me/home'

    def index
      set_roled_tabs
      sef_roled_menus
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

    def set_roled_menus
      @roled_menus = {
        'factory/agent/productions#index' => 'person-chalkboard',
        'trade/admin/payments#uncheck' => 'cash-register',
        'trade/admin/orders#index' => 'list',
        'trade/admin/orders#delivery' => 'list',
        'trade/in/orders#index' => 'list-check',
        'space/admin/desks#all' => 'chair',
        'factory/admin/products#index' => 'list-tree',
        'org/admin/members#index' => 'user-gear'
      }
    end

  end
end
