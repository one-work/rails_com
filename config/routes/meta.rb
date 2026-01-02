
namespace :meta do
  namespace :panel do

    resources :namespaces do
      collection do
        post :sync
      end
      member do
        patch :move_lower
        patch :move_higher
      end
    end
    resources :businesses do
      collection do
        post :sync
      end
      member do
        patch :move_lower
        patch :move_higher
      end
    end
    resources :controllers, only: [:index] do
      collection do
        post :sync
        post :meta_namespaces
        post :meta_controllers
        post :meta_actions
      end
      member do
        patch :move_lower
        patch :move_higher
      end
      resources :meta_actions do
        member do
          patch :move_lower
          patch :move_higher
          get :roles
        end
      end
    end
    resources :models do
      collection do
        post :sync
        post :options
        post :columns
      end
      member do
        get :reflections
        get :indexes
        post :index_edit
        post :index_update
        patch :reorder
      end
      resources :meta_columns do
        member do
          patch :sync
          patch :test
        end
      end
    end

  end
end