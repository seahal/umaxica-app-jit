# typed: false
# frozen_string_literal: true

scope module: :sign, as: :sign do
  constraints host: ENV["SIGN_SERVICE_URL"] do
    scope module: :app, as: :app do
      root to: "roots#index"

      resource :health, only: :show, defaults: { format: :html }

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

      namespace :web do
        namespace :v1 do
          namespace :in do
            namespace :email do
              # TODO: nusty code!, delete controller of this line
              resource :otp, only: :create, controller: :otps
            end
            namespace :telephone do
              # TODO: nusty code!, delete controller of this line
              resource :otp, only: :create, controller: :otps
            end
          end
        end
      end

      resource :up, only: :new
      namespace :up do
        resources :emails, only: %i(new create edit update)
        resources :telephones, only: %i(new create edit update) do
          collection do
            post :resend
          end
          # TODO: nusty code!
          resource :passkey_registration, only: %i(show create)
          # TODO: nusty code!
          post "passkey_registration/begin", to: "passkey_registrations#begin"
        end
      end

      resource :in, only: %i(new)
      namespace :in do
        resource :email, only: %i(new create edit update)
        # TODO: refactor to standard CRUD
        resources :passkeys, only: [:new] do
          collection do
            post :options
            post :verification
          end
        end
        resource :secret, only: %i(new create)
        resource :session, only: %i(show update destroy)
        resource :checkpoint, only: %i(show update destroy)
        resource :challenge, only: %i(show)
        namespace :challenge do
          resource :totp, only: %i(new create)
          resource :passkey, only: %i(new create)
        end
      end

      # Social auth: start sets intent/state then redirects to /auth/:provider
      namespace :social do
        get "start", to: "sessions#start"
        delete ":provider/unlink",
               to: "sessions#unlink",
               as: :unlink,
               constraints: { provider: /google_oauth2|apple/ }
      end
      # OmniAuth callbacks (GET for Google, POST for Apple)
      namespace :auth, path: "auth" do
        match ":provider/callback",
              to: "omniauth_callbacks#omniauth",
              via: %i(get post),
              as: :callback
        match "failure",
              to: "omniauth_callbacks#failure",
              via: %i(get post)
      end

      resource :verification, only: %i(show), controller: :verification
      namespace :verification do
        resource :setup, only: %i(new)
        resource :passkey, only: %i(new create)
        resource :totp, only: %i(new create)
        resources :emails, only: %i(new create edit update)
      end

      resource :configuration, only: %i(show edit)
      namespace :configuration do
        resources :totps, only: %i(index new create edit update destroy)
        # TODO: refactor to standard CRUD
        resources :passkeys do
          collection do
            post :options
            post :verification
          end
        end
        resource :challenge, only: %i(show update)
        namespace :emails do
          # TODO: nusty code!, delete controller of this line
          resource :registration, only: %i(new create edit update), controller: :registrations
        end
        resources :emails, only: %i(index edit destroy)
        namespace :telephones do
          # TODO: nusty code!, delete controller of this line
          resource :registration, only: %i(new create edit update), controller: :registrations
        end
        resources :telephones, only: %i(index new edit create destroy)
        resource :apple, only: [:show, :destroy]
        # TODO: by the way, what is update mehtods for google here?
        resource :google, only: %i(show update destroy)
        # TODO: refactor to standard CRUD
        resources :secrets, only: %i(index show new edit create destroy) do
          post :regenerate, on: :member
        end
        resources :sessions, only: %i(index destroy) do
          collection do
            delete :others
          end
        end
        resources :activities, only: :index
        resource :activity, only: :show, controller: :activities
        resource :out, only: %i(edit destroy)
        resource :withdrawal, only: %i(new update create edit destroy)
      end
    end
  end

  # Staff auth management
  constraints host: ENV["SIGN_STAFF_URL"] do
    scope module: :org, as: :org do
      root to: "roots#index"
      resource :health, only: :show, defaults: { format: :html }

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

      resource :up, only: :new

      resource :in, only: [:new]
      namespace :in do
        # TODO: refactor to standard CRUD
        resources :passkeys, only: [:new] do
          collection do
            post :options
            post :verification
          end
        end
        resource :secret, only: %i(new create)
        resource :session, only: %i(show update destroy)
        resource :checkpoint, only: %i(show update destroy)
        resource :challenge, only: %i(show create)
      end

      resource :verification, only: %i(show), controller: :verification
      namespace :verification do
        resource :setup, only: %i(new)
        resource :passkey, only: %i(new create)
        resource :totp, only: %i(new create)
      end

      resource :configuration, only: :show
      namespace :configuration do
        # Backward compatibility for tests/flows that still reference /configuration/totps.,
        # TODO: delete controller of this line
        get "totps", to: "challenges#show", as: :totps
        # TODO: refactor to standard CRUD
        resources :passkeys do
          collection do
            post :options
            post :verification
          end
        end
        resource :challenge, only: %i(show update)
        resources :secrets
        resources :sessions, only: %i(index destroy) do
          collection do
            delete :others
          end
        end
        resource :out, only: %i(edit destroy)
        resource :withdrawal, only: %i(show)
      end
    end
  end
end
