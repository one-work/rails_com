# frozen_string_literal: true

namespace :log do
  namespace :panel do

    root 'home#index'
    controller :home do
      get :index
    end

    resources :requests do
      collection do
        get :ip
        get :latest
      end
    end
    resources :queries
  end
end