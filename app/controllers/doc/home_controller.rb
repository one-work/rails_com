module Doc
  class HomeController < BaseController

    def index
    end

    private
    def set_home
      @home = Home.find(params[:id])
    end

    def home_params
      params.fetch(:home, {}).permit(
      )
    end

  end
end
