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
          resource :signed_in, only: :show
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

      resource :up, only: :new
      namespace :up do
        resources :emails, only: %i(new create edit update)
        resources :telephones, only: %i(new create edit update), param: :public_id do
          collection do
            post :resend
          end
          resource :passkey_registration, only: %i(show create)
          post "passkey_registration/begin", to: "passkey_registrations#begin"
        end
      end

      resource :in, only: %i(new)
      namespace :in do
        # TODO: add show/delete for 2FA
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
        resource :mfa, only: %i(show)
        namespace :mfa do
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

      resource :verification, only: %i(show)
      namespace :verification do
        resource :passkey, only: %i(new create)
        resource :totp, only: %i(new create)
        resources :emails, only: %i(new create edit update)
      end

      resource :configuration, only: :show
      namespace :configuration do
        # TODO: implement TOTP settings management
        resources :totps, only: %i(index new create edit update destroy), param: :public_id
        # TODO: refactor to standard CRUD
        resources :passkeys, param: :public_id do
          collection do
            post :options
            post :verification
          end
        end
        resource :mfa, only: %i(show update)
        resources :emails, only: %i(index edit update destroy)
        namespace :emails do
          resource :registration, only: %i(new create edit update), controller: :registrations
        end
        resources :telephones, only: %i(index edit update destroy)
        namespace :telephones do
          resource :registration, only: %i(new create edit update), controller: :registrations
        end
        resource :apple, only: [:show, :destroy]
        resource :google, only: %i(show update destroy)
        # refactor to standard CRUD
        resources :secrets, param: :public_id do
          post :regenerate, on: :member
        end
        # what is this?
        resource :emergency_key, only: :show
        # i want this code more precisely routing.
        resources :sessions
        resources :activities, only: :index
        resource :out, only: %i(edit destroy)
        # i want this code more precisely routing.
        resource :withdrawal
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
          resource :signed_in, only: :show
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
        resource :mfa, only: %i(show create)
      end

      resource :verification, only: %i(show)
      namespace :verification do
        resource :passkey, only: %i(new create)
        resource :totp, only: %i(new create)
      end

      resource :configuration, only: :show
      namespace :configuration do
        resources :totps, only: %i(index new create edit update destroy)
        # TODO: refactor to standard CRUD
        resources :passkeys do
          collection do
            post :options
            post :verification
          end
        end
        resource :mfa, only: %i(show update)
        resources :secrets, param: :public_id
        resources :sessions
        resource :out, only: %i(edit destroy)
        resource :withdrawal, only: %i(show)
      end
    end
  end
end
