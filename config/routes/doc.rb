namespace :doc, defaults: { business: 'doc' } do
  root 'home#index'
  controller :home do
    get :index
  end

  resources :subjects do
    member do
      get 'code/:meta_controller/:meta_action' => :code
    end
  end
end
