module Pg
  class Panel::SubscriptionsController < Panel::BaseController
    skip_before_action :require_member_or_user if whether_filter(:require_member_or_user)
    skip_before_action :require_role if whether_filter(:require_role)
    before_action :authenticate_by
    before_action :set_subscription, only: [:show, :edit]

    def index
      BaseRecord.connected_to(**shard_params) do
        @subscriptions = Subscription.page(params[:page])
      end
    end

    def new
      @subscription = Subscription.new
    end

    def create
      BaseRecord.connected_to(**shard_params) do
        Subscription.connection.exec_query(
          "CREATE SUBSCRIPTION #{subscription_params[:subname]} CONNECTION '#{conninfo_params}' PUBLICATION #{subscription_params[:pubname]}"
        )
      end
    end

    def update
      BaseRecord.connected_to(**shard_params) do
        @subscription = Subscription.find(params[:id])
        Subscription.connection.exec_query "ALTER SUBSCRIPTION #{@subscription.subname} CONNECTION '#{conninfo_params}'"
      end
    end

    def refresh
      BaseRecord.connected_to(**shard_params) do
        @subscription = Subscription.find(params[:id])
        Subscription.connection.exec_query "ALTER SUBSCRIPTION #{@subscription.subname} REFRESH PUBLICATION"
      end
    end

    def destroy
      BaseRecord.connected_to(**shard_params) do
        @subscription = Subscription.find(params[:id])
        Subscription.connection.exec_query "ALTER SUBSCRIPTION #{@subscription.subname} DISABLE"
        Subscription.connection.exec_query "ALTER SUBSCRIPTION #{@subscription.subname} SET (slot_name = NONE)"
        Subscription.connection.exec_query "DROP SUBSCRIPTION #{@subscription.subname}"
      end
    end

    private
    def set_subscription
      BaseRecord.connected_to(**shard_params) do
        @subscription = Subscription.find(params[:id])
      end
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
