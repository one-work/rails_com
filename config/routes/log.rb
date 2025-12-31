# frozen_string_literal: true

namespace :log do
  namespace :panel do
    resources :requests do
      collection do
        get :ip
        get :latest
      end
    end
    resources :queries
  end
end