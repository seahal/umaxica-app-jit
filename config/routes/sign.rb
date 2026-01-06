# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: :sign, as: :sign do
    # service page
    constraints host: ENV["SIGN_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
          resource :csrf, only: :show
        end
        # Sign up
        resource :up, only: :new
        namespace :up do
          resources :emails, only: %i(new create edit update)
          resources :passkeys, only: %i(new create edit update)
        end
        # Preferences
        resource :preference, only: :show
        # Sign in/out
        resource :in, only: %i(new)
        namespace :in do
          resource :email, only: %i(new create edit update)
          resource :passkey, only: %i(new create edit update)
          resource :secret, only: %i(new create)
        end
        # Social sign-up / log-in
        namespace :social do
          match "apple/callback", to: "sessions#create", defaults: { provider: "apple" }, via: %i(get post)
          get "google/callback", to: "sessions#create", defaults: { provider: "google_oauth2" }
        end
        # Settings with logged-in user
        resource :configuration, only: :show
        namespace :configuration do
          # TODO: Implement TOTP settings management
          resources :totps, only: %i(index new create edit)
          # TODO: Implement telephone settings management
          # resources :passkeys
          post "passkeys/challenge", to: "passkeys#challenge", as: :sign_app_configuration_passkeys_challenge
          post "passkeys/verify", to: "passkeys#verify", as: :sign_app_configuration_passkeys_verify
          resources :passkeys, only: %i(index show new create edit update destroy) do
            collection do
              post :challenge
              post :verify
            end
            resources :secrets, only: [:index], controller: "configuration/secrets"
          end
          # TODO: Implement email settings management
          resources :emails
          # TODO: Implement email settings management
          resources :telephones
          # sign in with ***
          resource :apple, only: [:show]
          resource :google, only: [:show]
          # TODO : Implement recovery code management
          resources :secrets
          # TODO: Implement connected apps management
          resources :sessions
          # Withdrawal
          resource :withdrawal
        end
        # Token refresh endpoint for JSON API clients (SPA, Mobile apps)
        namespace :token do
          resource :refresh, only: :create
        end
        # Sign out
        resource :out, only: [:edit, :destroy]
      end
    end

    # For Staff's Auth Management
    constraints host: ENV["SIGN_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
          resource :csrf, only: :show
        end
        # Sign up
        resource :up, only: :new
        # Login
        resource :in, only: [:new]
        namespace :in do
          resource :passkey, only: %i(new create edit update)
          resource :secret, only: %i(new create)
        end
        # Preferences
        resource :preference, only: :show
        # Settings
        resource :configuration, only: :show
        namespace :configuration do
          # TODO: Implement TOTP settings management
          resources :totps, only: %i(index new create edit)
          # resources :totp, only: [ :index, :new, :create, :edit, :update ]
          resources :passkeys, only: %i(index edit update new)
          # TODO: Implement email settings index
          # resources :emails, only: [ :index ]
          resources :secrets
          # TODO: Implement connected apps management
          resources :sessions
          # Withdrawal
          resource :withdrawal, only: %i(show)
        end
        # Token refresh endpoint for JSON API clients (SPA, Mobile apps)
        namespace :token do
          resource :refresh, only: :create
        end
        # Sign out
        resource :out, only: [:edit, :destroy]
        # TODO: move to configuration namespace
        resource :out, only: [:edit, :destroy]
      end
    end
  end
end
