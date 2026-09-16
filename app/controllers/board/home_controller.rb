module Board
  class HomeController < BaseController
    layout 'board/home'

    def index
      @once_token = Current.session.once_token
    end

  end
end
