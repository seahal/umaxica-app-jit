# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: :sign, as: :sign do
    # Service (User Authentication)
    constraints host: ENV["SIGN_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"

        # Health check
        resource :health, only: :show, defaults: { format: :html }

        # Edge API
        namespace :edge do
          namespace :v1 do
            resource :health, only: :show
            resource :csrf, only: :show
            namespace :token do
              resource :check, only: :show
              resource :refresh, only: :create
            end
          end
        end

        # Client API
        resource :client, only: :show, controller: :clients
        namespace :client do
          namespace :v1 do
            resource :health, only: :show
          end
        end

        # Sign up
        resource :up, only: :new
        namespace :up do
          resources :emails, only: %i[new create edit update show destroy]
          resources :telephones, only: %i[new create edit update show destroy]
        end

        # Sign in
        resource :in, only: %i[new]
        namespace :in do
          resource :session, only: %i[edit update]
          resource :email, only: %i[new create edit update]
          resources :passkeys, only: [ :new ] do
            collection do
              post :options
              post :verification
            end
          end
          resource :secret, only: %i[new create]
        end

        # Social Authentication (OmniAuth)
        namespace :social do
          post "start", to: "sessions#start"
          delete ":provider/unlink",
                 to: "sessions#unlink",
                 as: :unlink,
                 constraints: { provider: /google_oauth2|apple/ }
        end
        namespace :auth, path: "auth" do
          match ":provider/callback",
                to: "omniauth_callbacks#omniauth",
                via: %i[get post],
                as: :callback
          match "failure",
                to: "omniauth_callbacks#failure",
                via: %i[get post]
        end

        # Passkey (WebAuthn)
        resource :passkey, only: %i[new create update destroy] do
          collection { post :options }
        end

        # User settings
        resource :configuration, only: :show
        namespace :configuration do
          resources :totps, only: %i[index new create edit update destroy]
          resources :passkeys do
            collection do
              post :options, to: "passkeys#new", defaults: { format: :json }
              post :verification, to: "passkeys#create", as: :verification
            end
          end
          resources :emails
          resources :telephones
          resource :apple, only: [ :show, :destroy ]
          resource :google, only: %i[show update destroy]
          resources :secrets, only: %i[index new create edit show destroy]
          resources :sessions
          resource :security, only: [ :show, :update, :edit ]
          resource :withdrawal, only: %i[show new create edit update]
        end

        # Sign out
        resource :out, only: %i[edit destroy]
      end
    end

    # Staff Authentication
    constraints host: ENV["SIGN_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        resource :health, only: :show, defaults: { format: :html }

        # Edge API
        namespace :edge do
          namespace :v1 do
            resource :health, only: :show
            resource :csrf, only: :show
            namespace :token do
              resource :check, only: :show
              resource :refresh, only: :create
            end
          end
        end
        namespace :client do
          namespace :v1 do
            resource :health, only: :show
          end
        end

        # Sign up
        resource :up, only: :new

        # Sign in
        resource :in, only: [ :new ]
        namespace :in do
          resource :session, only: %i[edit update]
          resources :passkeys, only: [ :new ] do
            collection do
              post :options
              post :verification
            end
          end
          resource :secret, only: %i[new create]
        end

        # Staff settings
        resource :configuration, only: :show
        namespace :configuration do
          resources :totps, only: %i[index new create edit update destroy]
          resources :passkeys do
            collection do
              post :options, to: "passkeys#new", defaults: { format: :json }
              post :verification, to: "passkeys#create", as: :verification
            end
          end
          resources :sessions
          resources :secrets
          resource :security, only: [ :show, :edit, :update ]
          resource :withdrawal, only: %i[show]
        end

        # Sign out
        resource :out, only: %i[edit destroy]
      end
    end
  end
end
