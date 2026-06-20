# frozen_string_literal: true
get 'pg' => 'pg/panel/subscriptions#index'

namespace :pg, defaults: { business: 'pg' } do
  namespace :panel, defaults: { namespace: 'panel' } do
    resources :publications do
      collection do
        get :prod
        post :create_all
      end
      resources :publication_tables, only: [:index, :new, :create]
    end
    resources :replication_slots
    resources :subscriptions do
      member do
        post :refresh
      end
      resources :stat_subscriptions
    end
    resources :users
  end
end
