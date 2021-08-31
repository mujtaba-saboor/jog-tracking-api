# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :jogging_events, only: %i[create index destroy update] do
        collection do
          get 'weekly_report'
          post 'add_event'
        end

        member do
          delete 'destroy_event'
        end
      end
      resources :users do
        collection do
          get 'my_profile'
          put 'update_profile'
          delete 'delete_profile'
          post 'add_user'
        end
      end
      post 'login', to: 'user_authentication#login'
      post 'signup', to: 'users#create'
    end
  end

  match '/*path', controller: 'api/v1/errors', action: 'error_four_zero_four', via: :all
  root to: 'api/v1/errors#error_four_zero_four', via: :all
end
