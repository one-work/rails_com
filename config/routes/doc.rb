namespace :doc, defaults: { business: 'doc' } do
  root 'home#index'
  controller :home do
    get :index
  end

  resources :subjects do
    collection do
      get 'code/:meta_controller/:meta_action' => :code
    end
  end
end
