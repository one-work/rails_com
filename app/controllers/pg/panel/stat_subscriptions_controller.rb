module Pg
  class Panel::StatSubscriptionsController < Panel::BaseController
    skip_before_action :require_member_or_user if whether_filter(:require_member_or_user)
    skip_before_action :require_role if whether_filter(:require_role)
    before_action :authenticate_by
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
