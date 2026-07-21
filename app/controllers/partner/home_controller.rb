module Partner
  class HomeController < BaseController
    skip_before_action :require_role, only: [:index] if whether_filter :require_role

    def index
      set_roled_tabs
      @share = {
        url: 'https://one.work/factory/productions',
        title: '官方商场',
        appId: 'wxe44dc002dd0d29b0'
      }

      if current_organ
        if request.variant.include? :mini_program
          host = current_organ.mp_host
        else
          host = current_organ.host
        end
        @organ_tabs = current_organ.tabs.where(namespace: '').pluck(:path)

        @share.merge!(
          title: current_organ.name,
          debug: current_organ.debug_enabled,
          url: url_for(controller: 'org/organs', host: host)
        )

        if current_organ.share_logo.attached?
          @share.merge!(share_logo: current_organ.share_logo_url)
        end
      end
    end

  end
end
