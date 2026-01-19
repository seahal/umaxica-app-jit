# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: :sign, as: :sign do
    # service page
    constraints host: ENV["SIGN_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"

        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }

        # Edge API endpoint (browser/SPA)
        namespace :edge do
          namespace :v1 do
            resource :health, only: :show
            resource :csrf, only: :show
            # REST-ish token endpoints:
            # GET  /edge/v1/token/check   -> checks#show
            # POST /edge/v1/token/refresh -> refreshes#create
            namespace :token do
              resource :check, only: :show
              resource :refresh, only: :create
            end
          end
        end

        # Sign up
        resource :up, only: :new
        namespace :up do
          resources :emails, only: %i(new create edit update)
          resources :passkeys, only: %i(new create edit update)
        end

        # Sign in/out
        resource :in, only: %i(new)
        namespace :in do
          resource :email, only: %i(new create edit update)
          resource :passkey, only: %i(new create edit update)
          resource :totp, only: %i(new create)
          resource :secret, only: %i(new create)
        end

        # Social sign-up / log-in
        namespace :social do
          match "apple/callback",
                to: "sessions#create",
                defaults: { provider: "apple" },
                via: %i(get post)
          get "google/callback",
              to: "sessions#create",
              defaults: { provider: "google_oauth2" }
        end

        # Settings with logged-in user
        resource :configuration, only: :show
        namespace :configuration do
          # TODO: Implement TOTP settings management
          resources :totps, only: %i(index new create edit)

          post "passkeys/challenge",
               to: "passkeys#challenge",
               as: :sign_app_configuration_passkeys_challenge
          post "passkeys/verify",
               to: "passkeys#verify",
               as: :sign_app_configuration_passkeys_verify

          resources :passkeys, only: %i(index show new create edit update destroy) do
            collection do
              post :challenge
              post :verify
            end
            resources :secrets, only: [:index], controller: "configuration/secrets"
          end
          resources :emails
          resources :telephones
          resource :apple, only: [:show]
          resource :google, only: [:update]
          resources :secrets do
            post :regenerate, on: :member
          end
          resources :sessions
          resource :withdrawal
        end

        # Sign out
        resource :out, only: %i(edit destroy)
      end
    end

    # For Staff's Auth Management
    constraints host: ENV["SIGN_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"

        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }

        # Edge API endpoint (browser/SPA)
        namespace :edge do
          namespace :v1 do
            resource :health, only: :show
            resource :csrf, only: :show

            # REST-ish token endpoints:
            # GET  /edge/v1/token/check   -> checks#show
            # POST /edge/v1/token/refresh -> refreshes#create
            namespace :token do
              resource :check, only: :show
              resource :refresh, only: :create
            end
          end
        end

        # Sign up
        resource :up, only: :new

        # Login
        resource :in, only: [:new]
        namespace :in do
          resource :passkey, only: %i(new create edit update)
          resource :secret, only: %i(new create)
        end

        # Settings
        resource :configuration, only: :show
        namespace :configuration do
          resources :totps, only: %i(index new create edit)
          resources :passkeys, only: %i(index edit update new)
          resources :secrets
          resources :sessions
          resource :withdrawal, only: %i(show)
        end

        # Sign out
        resource :out, only: %i(edit destroy)
      end
    end
  end
end
