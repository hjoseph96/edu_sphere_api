Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "welcome#index"

  
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :create, :update]
      resources :sessions, only: :create
      resources :documents do
        member do
          get :download
          get :analytics
          get :version_history
          post :add_editors
          post :restore_version
        end

        collection do
          get :user_analytics
          get :system_analytics
        end
      end
    end

  end
end
