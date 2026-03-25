module Pg
  class Panel::StatSubscriptionsController < Panel::BaseController
    before_action :set_subscription

    def index
      @stat_subscriptions = @subscription.stat_subscriptions
    end

    private
    def set_subscription
      @subscription = Subscription.find params[:subscription_id]
    end

  end
end
