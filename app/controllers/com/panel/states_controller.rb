module Com
  class Panel::StatesController < Panel::BaseController
    before_action :set_state, only: [:show, :destroy]

    def index
      @states = State.order(created_at: :desc).page(params[:page])
    end

    private
    def set_state
      @state = State.find(params[:id])
    end

  end
end
