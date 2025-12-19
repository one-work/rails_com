Rails.application.routes.draw do
  draw :job
  draw :pg
  draw :roled
  draw :statis

  scope 'rails/active_storage', module: :com, defaults: { business: 'com' } do
    resources :direct_uploads, only: [:create]
    resources :disk, param: :encoded_token, only: [:update]
  end

  controller :home do
    get :index
  end

  namespace :board, defaults: { namespace: 'board' } do
    root 'home#index' unless has_named_route? 'board_root'
  end

  namespace :panel, defaults: { namespace: 'panel' } do
    root 'home#index' unless has_named_route? 'panel_root'
  end

  namespace :admin, defaults: { namespace: 'admin' } do
    root 'home#index' unless has_named_route? 'admin_root'
  end

  namespace :my do
    root 'home#index' unless has_named_route? 'my_root'
  end

  namespace :me, defaults: { namespace: 'me' } do
    root 'home#index' unless has_named_route? 'me_root'
  end

  namespace :our, defaults: { namespace: 'our' } do
    root 'home#index' unless has_named_route? 'our_root'
  end

  scope :rails, module: 'com', as: :rails_ext, defaults: { business: 'com' } do
    resources :videos, only: [:show] do
      member do
        put :transfer
      end
    end
    resources :audios, only: [:show] do
      member do
        put :transfer
      end
    end
    resources :pdfs, only: [:show] do
      member do
        get :png
        get :jpg
      end
    end
  end

  scope module: 'com', defaults: { business: 'com' } do
    controller :common do
      get :infos
      get :cache_list
      get :enum_list
      get :qrcode
      get :test_raise
      get :cancel
      post :actions
      match :deploy, via: [:get, :post]
      get :state_return
      get 'assets/*path' => :asset, constraints: ->(req) { [:jpeg, :png, :webp].include? req.format.symbol }
    end
    controller :log do
      get '/not_founds' => :index
      post '/csp_violation_report' => :csp
    end
    resources :nodes, only: [] do
      collection do
        get :children
        get :outer
        get :outer_search
      end
    end
    resources :blob_temps
  end

  namespace :com, defaults: { business: 'com' } do
    namespace :my, defaults: { namespace: 'my' } do
      resources :ssh_keys do
        member do
          post :deploy
          get :remote_status
        end
      end
    end
    namespace :admin, defaults: { namespace: 'admin' } do
      resource :organ
      resources :filters do
        collection do
          post :detect
          post :column
          post :column_single
        end
      end
      resources :blob_defaults do
        collection do
          match :add, via: [:get, :post]
          post :sync
        end
      end
    end
    namespace :panel, defaults: { namespace: 'panel' } do
      root 'home#index'
      scope path: 'puma' do
        controller :puma do
          get :stats
          get :thread_stats
        end
      end
      resource :organ
      resources :detectors do
        resources :detector_logs
        resources :detector_errors
      end
      resources :err_summaries, only: [:index, :show, :destroy] do
        member do
          delete :clean
        end
        resources :errs, only: [:index, :show, :destroy] do
          collection do
            delete :batch_destroy
          end
          member do
            delete :clean_other
          end
        end
      end
      resources :err_bots
      resources :logs do
        collection do
          get :ip
        end
      end
      resources :log_sqls
      resources :csps, only: [:index, :show, :destroy]
      resources :states
      resources :meta_namespaces do
        collection do
          post :sync
        end
        member do
          patch :move_lower
          patch :move_higher
        end
      end
      resources :meta_businesses do
        collection do
          post :sync
        end
        member do
          patch :move_lower
          patch :move_higher
        end
      end
      resources :meta_controllers, only: [:index] do
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
      resources :meta_models do
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
      resources :infos
      resources :cache_lists
      resources :inbound_emails
      resources :attachments, only: [:index, :show, :destroy] do
        collection do
          get :garbled
        end
        member do
          delete :delete
        end
      end
      resources :blobs, only: [:index, :show, :new, :create, :destroy] do
        collection do
          get :unattached
        end
      end
      resources :blob_defaults do
        collection do
          match :add, via: [:get, :post]
          post :sync
        end
      end
      resources :acme_servicers
      resources :acme_accounts do
        resources :acme_orders do
          member do
            patch :order
            patch :verify
            patch :cert
          end
        end
        resources :acme_orders, only: [] do
          resources :acme_identifiers, only: [:index, :new, :create]
          resources :acme_identifiers, only: [:show, :edit, :update, :destroy]
        end
      end
      resources :ssh_keys
      resources :pg_publications do
        collection do
          post :create_all
        end
        resources :pg_publication_tables, only: [:index, :new, :create]
      end
      resources :pg_replication_slots
    end
  end
end

Rails.application.routes.append do
  match '*all', controller: 'com/common', action: 'cors_preflight_check', via: [:options]
  get 'up', controller: 'com/common', action: 'up'
end

Rails.application.routes.append do
  match '*path' => 'com/log#not_found', via: [:get, :post]
end if RailsCom.config.intercept_not_found
