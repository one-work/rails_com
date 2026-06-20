module Pg
  class Panel::UsersController < Panel::BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.includes(:role).page(params[:page])
    end

    def new
      @user = User.new
    end

    def create
      User.connection.exec_query "CREATE USER #{user_params[:usename]} WITH PASSWORD '#{user_params[:password]}'"
    end

    def update
      User.connection.exec_query "ALTER USER #{@user.usename} RENAME TO #{user_params[:usename]}"
    end

    def destroy
      User.connection.exec_query "DROP USER #{@user.usename}"
    end

    private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.fetch(:user, {}).permit(
        :usename,
        :password
      )
    end

  end
end
