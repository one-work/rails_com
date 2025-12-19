module Com
  module Model::PgSubscription
    extend ActiveSupport::Concern

    included do
      has_many :pg_stat_subscriptions, primary_key: :subname, foreign_key: :subname
    end

  end
end
