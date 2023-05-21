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
        post 'verify', to: 'auth#confirm_verification'
        post 'login', to: 'auth#login', as: 'login'
        put 'logout', to: 'auth#logout', as: 'logout'
        post 'password_reset', to: 'auth#password_reset'
        post 'confirm_reset', to: 'auth#confirm_password_reset'
        post 'send_code', to: 'auth#send_code'
      end
    end
  end
end
