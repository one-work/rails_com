module Pg
  class Panel::UsersController < Panel::BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.page(params[:page])
    end

    def new
      @user = User.new
    end

    def create
      allow_tables = @tables & user_params[:tables].compact_blank!
      User.connection.exec_query "CREATE PUBLICATION #{user_params[:pubname]} FOR TABLE #{allow_tables.join(', ')}"
    end

    def update
      allow_tables = @tables & user_params[:tables].compact_blank!
      User.connection.exec_query "ALTER PUBLICATION #{@user.pubname} SET TABLE #{allow_tables.join(', ')}"
    end

    private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.fetch(:user, {}).permit(
        :pubname,
        tables: []
      )
    end

  end
end
