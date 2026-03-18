# typed: false
# frozen_string_literal: true

require Rails.root.join("lib/sign_host_env").to_s

scope module: :sign, as: :sign do
  constraints host: SignHostEnv.service_url do
    scope module: :app, as: :app do
      root to: "roots#index"

      resource :health, only: :show, defaults: { format: :html }
      resource :sitemap, only: :show, defaults: { format: :xml }

      namespace :edge do
        namespace :v0 do
          resource :health, only: :show
          resource :sitemap, only: :show
          namespace :token do
            resource :check, only: :show
            resource :dbsc_registration, only: :create
            resource :refresh, only: :create
          end
        end
      end

      namespace :web do
        namespace :v0 do
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

      # Social auth: new sets intent/state then redirects to /auth/:provider
      namespace :social do
        resource :session, only: [:new]
        delete ":provider/unlink",
               to: "sessions#unlink",
               as: :unlink,
               constraints: { provider: /google_app|apple/ }
      end

      # OmniAuth callbacks (GET for Google, POST for Apple)
      namespace :auth, path: "auth" do
        match ":provider/callback",
              to: "omniauth_callbacks#omniauth",
              via: %i(get post),
              as: :callback
        get "failure",
            to: "omniauth_callbacks#failure"
      end

      # step up verification
      resource :verification, only: %i(show), controller: :verification
      namespace :verification do
        resource :setup, only: %i(new)
        resource :passkey, only: %i(new create)
        resource :totp, only: %i(new create)
        resources :emails, only: %i(new create edit update)
      end

      # OIDC
      resource :authorize, only: %i(show)
      resource :token, only: %i(show)
      resource :jwks, only: %i(show)

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

      resource :preference, only: :show
      namespace :preference do
        resources :email, only: %i(index show create edit update), controller: :emails
      end
    end
  end

  # Staff auth management
  constraints host: SignHostEnv.staff_url do
    scope module: :org, as: :org do
      root to: "roots#index"

      resource :health, only: :show, defaults: { format: :html }
      resource :sitemap, only: :show, defaults: { format: :xml }

      namespace :edge do
        namespace :v0 do
          resource :health, only: :show
          resource :sitemap, only: :show
          namespace :token do
            resource :check, only: :show
            resource :dbsc_registration, only: :create
            resource :refresh, only: :create
          end
        end
      end

      resource :up, only: :new

      # Social auth: Google sign-in for staff (login only, no sign-up)
      namespace :social do
        resource :session, only: [:new]
      end
      # OmniAuth callbacks (GET for Google)
      namespace :auth, path: "auth" do
        match ":provider/callback",
              to: "omniauth_callbacks#omniauth",
              via: %i(get post),
              as: :callback
        get "failure",
            to: "omniauth_callbacks#failure"
      end

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
      end

      # OIDC
      resource :authorize, only: %i(show)
      resource :token, only: %i(show)
      resource :jwks, only: %i(show)

      resource :configuration, only: :show
      namespace :configuration do
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
