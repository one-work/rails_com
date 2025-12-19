module Com
  class Panel::ErrBotsController < Panel::BaseController
    before_action :set_err_bot, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}

      @err_bots = ErrBot.page(params[:page])
    end

    def edit
      @err_bot.err_notices.build if @err_bot.err_notices.blank?
    end

    private
    def set_err_bot
      @err_bot = ErrBot.find(params[:id])
    end

    def err_bot_params
      params.fetch(:err_bot, {}).permit(
        :type,
        :hook_url,
        :first_time,
        :secret,
        err_notices_attributes: {}
      )
    end

  end
end
