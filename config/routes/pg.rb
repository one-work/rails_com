# frozen_string_literal: true
get 'pg' => 'pg/panel/subscriptions#index'

namespace :pg, defaults: { business: 'pg' } do
  namespace :panel, defaults: { namespace: 'panel' } do
    resources :subscriptions do
      member do
        post :refresh
      end
      resources :stat_subscriptions
    end
  end
end
