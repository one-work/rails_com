module Admin
  class HomeController < BaseController

    def index
      @businesses = Meta::Business.includes(:admin_actions).where.not(identifier: ['', 'design'])
    end

  end
end
