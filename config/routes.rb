Rails.application.routes.draw do
  namespace :api do
    namespace :auth do
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
      get '/me', to: 'sessions#me'
    end
    namespace :v1 do
      resources :products
      resources :categories
      resource :cart, controller: 'carts', only: [:show] do
        post 'add_item', to: 'carts#add_item'
        patch 'update_item', to: 'carts#update_item'
        delete 'remove_item', to: 'carts#remove_item'
      end
      resources :orders do
        member do
          patch 'approve'
        end
      end
      resources :users, only: [:show, :update, :create] do
        member do
          patch 'activate'
          patch 'deactivate'
          patch 'assign_admin'
          patch 'remove_admin'
        end
      end
      resources :users, only: [:index]
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
