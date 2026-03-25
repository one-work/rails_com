module Pg
  module Model::Subscription
    extend ActiveSupport::Concern

    included do
      has_many :stat_subscriptions, primary_key: :subname, foreign_key: :subname
    end

  end
end
