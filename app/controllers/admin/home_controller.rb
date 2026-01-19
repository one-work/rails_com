module Admin
  class HomeController < BaseController
    skip_before_action :require_role, only: [:index] if whether_filter :require_role

    def index
      @businesses = Meta::Business.includes(:admin_actions).where.not(identifier: ['', 'design'])

      response.headers['Access-Control-Allow-Headers'] = 'Timezone'
    end

  end
end
