module Pg
  class Panel::SubscriptionsController < Panel::BaseController
    before_action :set_tables
    before_action :set_subscription, only: [:show, :edit, :update, :destroy, :refresh]

    def index
      @subscriptions = Subscription.page(params[:page])
    end

    def new
      @subscription = Subscription.new
    end

    def create
      Subscription.connection.exec_query(
        "CREATE SUBSCRIPTION #{subscription_params[:subname]} CONNECTION '#{conninfo_params}' PUBLICATION #{subscription_params[:pubname]}"
      )
    end

    def update
      Subscription.connection.exec_query "ALTER SUBSCRIPTION #{@subscription.subname} CONNECTION '#{conninfo_params}'"
    end

    def refresh
      Subscription.connection.exec_query "ALTER SUBSCRIPTION #{@subscription.subname} REFRESH PUBLICATION"
    end

    def destroy
      Subscription.connection.exec_query "ALTER SUBSCRIPTION #{@subscription.subname} DISABLE"
      Subscription.connection.exec_query "ALTER SUBSCRIPTION #{@subscription.subname} SET (slot_name = NONE)"
      Subscription.connection.exec_query "DROP SUBSCRIPTION #{@subscription.subname}"
    end

    private
    def set_tables
      @tables = ApplicationRecord.connection.tables
    end

    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    def conninfo_params
      _p = params.fetch(:subscription, {}).permit(
        :host,
        :port,
        :dbname,
        :user,
        :password
      )
      _p.to_h.each_with_object([]) { |(k, v), h| h << "#{k}=#{v}" }.join(' ')
    end

    def subscription_params
      params.fetch(:subscription, {}).permit(
        :subname,
        :pubname
      )
    end

  end
end
