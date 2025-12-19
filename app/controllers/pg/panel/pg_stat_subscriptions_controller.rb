module Pg
  class Panel::PgStatSubscriptionsController < Panel::BaseController
    before_action :set_pg_subscription

    def index
      @pg_stat_subscriptions = @pg_subscription.pg_stat_subscriptions
    end

    private
    def set_pg_subscription
      @pg_subscription = PgSubscription.find params[:pg_subscription_id]
    end

  end
end
