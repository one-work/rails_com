namespace :doc, defaults: { business: 'doc' } do
  root 'home#index'
  controller :home do
    get :index
  end
end
