# frozen_string_literal: true

namespace :pg, defaults: { business: 'pg' } do
  namespace :panel, defaults: { namespace: 'panel' } do
    resources :pg_subscriptions do
      member do
        post :refresh
      end
      resources :pg_stat_subscriptions
    end
  end
end
