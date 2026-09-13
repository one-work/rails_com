module Board
  class HomeController < BaseController

    def index
      @once_token = Current.session.once_token
    end

  end
end
