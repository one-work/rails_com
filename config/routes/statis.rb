
namespace :statis, defaults: { business: 'statis' } do
  namespace :panel, defaults: { namespace: 'panel' } do
    resources :statistics, only: [] do
      collection do
        get :statistical
      end
    end
    resources :configs do
      resources :statistics do
        collection do
          get :months
          get 'month/:month' => :month
          post 'do_cache/:month' => :do_cache
        end
        resources :statistic_days
      end
      resources :counters do
        collection do
          get :months
          get 'month/:month' => :month
          post 'do_cache/:month' => :do_cache
        end
      end
      resources :counter_days
    end
  end
end