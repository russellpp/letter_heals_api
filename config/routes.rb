# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # admin
      scope '/admin' do
      end

      # users
      resources :users, only: %i[index create show update] do
        collection do
          resources :posts, only: %i[index create show update]
          resources :messages, only: %i[index create show]
        end
      end
      post 'register', to: 'users#create', as: 'register'

      # auth
      scope '/auth' do
        post 'login', to: 'auth#login', as: 'login'
        put 'logout', to: 'auth#logout', as: 'logout'
        post 'request_code', to: 'auth#request_code'
        post 'verify', to: 'auth#verify'
      end
    end
  end
end
