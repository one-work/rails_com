module Admin
  class HomeController < BaseController
    skip_before_action :require_role, only: [:index] if whether_filter :require_role

    def index
      @meta_businesses = Com::MetaBusiness.where.not(identifier: '')
    end

  end
end
