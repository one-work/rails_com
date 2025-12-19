module Me
  class HomeController < BaseController
    skip_before_action :require_role, only: [:index] if whether_filter :require_role
    skip_before_action :require_org_member, only: [:index] if whether_filter :require_org_member
    before_action :require_member_or_user, only: [:index]

    def index
      set_roled_tabs

      @share = {
        url: 'https://one.work/factory/productions',
        title: '官方商场'
      }

      if current_organ
        @organ_tabs = current_organ.tabs.where(namespace: '').pluck(:path)

        @share.merge!(
          url: url_for(controller: 'factory/productions', host: current_organ.host, only_path: false),
          title: current_organ.name,
          debug: current_organ.debug_enabled
        )

        if current_organ.share_logo.attached?
          @share.merge!(share_logo: current_organ.share_logo_url)
        end
      end
    end

    private
    def require_member_or_user
      return if current_member
      return if current_user
      require_user
    end

  end
end
