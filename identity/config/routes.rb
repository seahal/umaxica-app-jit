# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Identity/Sign routes - Authentication, passkeys, OIDC, and social login
  # These endpoints require permanent URL stability

  # SignHostEnv is available via shared/lib/sign_host_env.rb

  # Define constraints that allow any host if the specific ENV is not set.
  # This facilitates development on localhost without complex setup.
  app_constraints = ->(request) { SignHostEnv.service_url.blank? || request.host == SignHostEnv.service_url }
  com_constraints = ->(request) { SignHostEnv.corporate_url.blank? || request.host == SignHostEnv.corporate_url }
  org_constraints = ->(request) { SignHostEnv.staff_url.blank? || request.host == SignHostEnv.staff_url }
  dev_constraints = ->(request) { SignHostEnv.dev_url.blank? || request.host == SignHostEnv.dev_url }
  net_constraints = ->(request) { SignHostEnv.net_url.blank? || request.host == SignHostEnv.net_url }

  scope module: :sign, as: :sign do
    # User auth service (sign.app domain)
    constraints app_constraints do
      scope module: :app, as: :app do
        root to: "roots#index"
        # Health
        resource :health, only: :show
        # Robots
        resource :robots, only: :show, path: "robots.txt"
        # Sitemap
        resource :sitemap, only: :show, path: "sitemap.xml"
        # Public web API: OTP delivery, cookie consent, theme
        namespace :web do
          namespace :v0 do
            resource :health, only: :show
            namespace :in do
              namespace :email do
                resource :otp, only: :create
              end
              namespace :telephone do
                resource :otp, only: :create
              end
            end
            resource :cookie, only: %i(show update)
            resource :theme, only: %i(show update)
          end
        end

        # Edge API: token lifecycle management (check, DBSC binding, refresh)
        namespace :edge do
          namespace :v0 do
            resource :health, only: :show
            namespace :token do
              resource :check, only: :show
              resource :dbsc, only: :create
              resource :refresh, only: :create
            end
          end
        end

        # preferences
        resource :preference, only: [:show]
        namespace :preference do
          # for region settings.
          resource :region, only: [:edit, :update]
          namespace :region do
            # for lx and tz settings.
            resource :timezone, only: [:edit, :update]
            resource :language, only: [:edit, :update]
          end
          # for dark/light mode
          resource :theme, only: [:edit, :update]
          # endpoint of reset preferences.
          resource :reset, only: [:edit, :destroy]
          # for ePrivacy settings.
          resource :cookie, only: [:edit, :update]
          resource :email, only: %i(new create edit update) do
            post :unsubscribe, on: :member
          end
        end

        # Sign-up: account registration via email or telephone
        resource :up, only: :new
        namespace :up do
          resources :emails, only: %i(new create edit update)
          resources :telephones, only: %i(new create edit update) do
            collection do
              post :resend
            end
            resource :passkey_registration, only: %i(show create) do
              post :begin, on: :member
            end
          end
        end

        # Sign-in: credential entry and session establishment
        resource :in, only: %i(new)
        namespace :in do
          resource :email, only: %i(new create edit update)
          resources :passkeys, only: [:new] do
            collection do
              post :options
              post :verification
            end
          end
          resource :secret, only: %i(new create)
          resource :session, only: %i(show update destroy)
          resource :bulletin, only: %i(show update destroy)
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

        # Step-up verification
        resource :verification, only: %i(show)
        namespace :verification do
          resource :setup, only: %i(new)
          resource :passkey, only: %i(new create)
          resource :totp, only: %i(new create)
          resources :emails, only: %i(new create edit update)
        end

        # OIDC
        resource :authorize, only: %i(show)
        resource :token, only: %i(create), defaults: { format: :json }
        resource :jwks, only: %i(show), defaults: { format: :json }

        # Account settings and linked identity management
        resource :configuration, only: %i(show edit)
        namespace :configuration do
          resources :totps, only: %i(index new create edit update destroy)
          resources :passkeys do
            collection do
              post :options
              post :verification
            end
          end
          resource :challenge, only: %i(show update)
          namespace :emails do
            resource :registration, only: %i(new create edit update)
          end
          resources :emails, only: %i(index edit destroy)
          namespace :telephones do
            resource :registration, only: %i(new create edit update)
          end
          resources :telephones, only: %i(index new edit create destroy)
          resource :apple, only: [:show, :destroy]
          resource :google, only: :show
          resources :secrets, only: %i(index show new edit create destroy) do
            post :regenerate, on: :member
          end
          resources :sessions, only: %i(index destroy) do
            collection do
              delete :others
            end
          end
          resources :activities, only: :index
          resource :out, only: %i(edit destroy)
          resource :withdrawal, only: %i(new update create edit destroy)
        end
      end
    end

    # Corporate sign service (sign.com domain)
    constraints com_constraints do
      scope module: :com, as: :com do
        root to: "roots#index"

        # Health
        resource :health, only: :show
        # Robots
        resource :robots, only: :show, path: "robots.txt"
        # Sitemap
        resource :sitemap, only: :show, path: "sitemap.xml"

        # Public web API: OTP delivery, cookie consent, theme
        namespace :web do
          namespace :v0 do
            namespace :in do
              namespace :email do
                resource :otp, only: :create
              end
              namespace :telephone do
                resource :otp, only: :create
              end
            end
            resource :cookie, only: %i(show update)
            resource :theme, only: %i(show update)
          end
        end

        # preferences
        resource :preference, only: [:show]
        namespace :preference do
          # for region settings.
          resource :region, only: [:edit, :update]
          namespace :region do
            # for lx and tz settings.
            resource :timezone, only: [:edit, :update]
            resource :language, only: [:edit, :update]
          end
          # for dark/light mode
          resource :theme, only: [:edit, :update]
          resource :cookie, only: [:edit, :update]
          # endpoint of reset preferences.
          resource :reset, only: [:edit, :destroy]
          resource :email, only: %i(new create edit update) do
            post :unsubscribe, on: :member
          end
        end

        # Sign-up: email registration
        resource :up, only: :new
        namespace :up do
          resources :emails, only: %i(new create edit update)
        end

        # Sign-in: credential entry and session establishment
        resource :in, only: %i(new)
        namespace :in do
          resource :email, only: %i(new create edit update)
          resources :passkeys, only: [:new] do
            collection do
              post :options
              post :verification
            end
          end
          resource :secret, only: %i(new create)
          resource :session, only: %i(show update destroy)
          resource :bulletin, only: %i(show update destroy)
          resource :challenge, only: %i(show)
          namespace :challenge do
            resource :totp, only: %i(new create)
            resource :passkey, only: %i(new create)
          end
        end

        # Step-up verification
        resource :verification, only: %i(show)
        namespace :verification do
          resource :setup, only: %i(new)
          resource :passkey, only: %i(new create)
          resource :totp, only: %i(new create)
          resources :emails, only: %i(new create edit update)
        end

        resource :authorize, only: %i(show)
        resource :token, only: %i(create), defaults: { format: :json }
        resource :jwks, only: %i(show), defaults: { format: :json }

        # Account settings and linked identity management
        resource :configuration, only: %i(show edit)
        namespace :configuration do
          resources :totps, only: %i(index new create edit update destroy)
          resources :passkeys do
            collection do
              post :options
              post :verification
            end
          end
          resource :challenge, only: %i(show update)
          resources :emails, only: %i(index edit destroy)
          namespace :emails do
            resource :registration, only: %i(new create edit update)
          end
          resources :telephones, only: %i(index new edit create destroy)
          namespace :telephones do
            resource :registration, only: %i(new create edit update)
          end
          resources :secrets, only: %i(index show new edit create destroy)
          resources :sessions, only: %i(index destroy) do
            collection do
              delete :others
            end
          end
          resources :activities, only: :index
          resource :out, only: %i(edit destroy)
          resource :withdrawal, only: %i(new update create edit destroy)
        end
      end
    end

    # Staff auth management
    constraints org_constraints do
      scope module: :org, as: :org do
        root to: "roots#index"
        # Health
        resource :health, only: :show
        # Robots
        resource :robots, only: :show, path: "robots.txt"
        # Sitemap
        resource :sitemap, only: :show, path: "sitemap.xml"
        # Public web API: OTP delivery, cookie consent, theme
        namespace :web do
          namespace :v0 do
            resource :health, only: :show
            namespace :in do
              namespace :email do
                resource :otp, only: :create
              end
              namespace :telephone do
                resource :otp, only: :create
              end
            end
            resource :cookie, only: %i(show update)
            resource :theme, only: %i(show update)
          end
        end

        # Edge API: token lifecycle management (check, DBSC binding, refresh)
        namespace :edge do
          namespace :v0 do
            resource :health, only: :show
            namespace :token do
              resource :check, only: :show
              resource :dbsc, only: :create
              resource :refresh, only: :create
            end
          end
        end

        # preferences
        resource :preference, only: [:show]
        namespace :preference do
          # for region settings.
          resource :region, only: [:edit, :update]
          namespace :region do
            # for lx and tz settings.
            resource :timezone, only: [:edit, :update]
            resource :language, only: [:edit, :update]
          end
          # for dark/light mode
          resource :theme, only: [:edit, :update]
          # endpoint of reset preferences.
          resource :reset, only: [:edit, :destroy]
          # for ePrivacy settings.
          resource :cookie, only: [:edit, :update]
          resource :email, only: %i(new create edit update) do
            post :unsubscribe, on: :member
          end
        end

        # Sign-up: account registration via email or telephone
        resource :up, only: :new
        namespace :up do
          resources :emails, only: %i(new create edit update)
          resources :telephones, only: %i(new create edit update) do
            collection do
              post :resend
            end
            resource :passkey_registration, only: %i(show create) do
              post :begin, on: :member
            end
          end
        end

        # Sign-in: credential entry and session establishment
        resource :in, only: %i(new)
        namespace :in do
          resource :email, only: %i(new create edit update)
          resources :passkeys, only: [:new] do
            collection do
              post :options
              post :verification
            end
          end
          resource :secret, only: %i(new create)
          resource :session, only: %i(show update destroy)
          resource :bulletin, only: %i(show update destroy)
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

        # Step-up verification
        resource :verification, only: %i(show)
        namespace :verification do
          resource :setup, only: %i(new)
          resource :passkey, only: %i(new create)
          resource :totp, only: %i(new create)
          resources :emails, only: %i(new create edit update)
        end

        # OIDC
        resource :authorize, only: %i(show)
        resource :token, only: %i(create), defaults: { format: :json }
        resource :jwks, only: %i(show), defaults: { format: :json }

        # Account settings and linked identity management
        resource :configuration, only: %i(show edit)
        namespace :configuration do
          resources :totps, only: %i(index new create edit update destroy)
          resources :passkeys do
            collection do
              post :options
              post :verification
            end
          end
          resource :challenge, only: %i(show update)
          namespace :emails do
            resource :registration, only: %i(new create edit update)
          end
          resources :emails, only: %i(index edit destroy)
          namespace :telephones do
            resource :registration, only: %i(new create edit update)
          end
          resources :telephones, only: %i(index new edit create destroy)
          resource :apple, only: [:show, :destroy]
          resource :google, only: :show
          resources :secrets, only: %i(index show new edit create destroy) do
            post :regenerate, on: :member
          end
          resources :sessions, only: %i(index destroy) do
            collection do
              delete :others
            end
          end
          resources :activities, only: :index
          resource :out, only: %i(edit destroy)
          resource :withdrawal, only: %i(new update create edit destroy)
        end
      end
    end

    # Developer and operational tooling
    constraints dev_constraints do
      scope module: :dev, as: :dev do
        root to: "roots#index"
        resource :health, only: :show
      end
    end

    # Private internal-service audience
    constraints net_constraints do
      scope module: :net, as: :net do
        root to: "roots#index"
        resource :health, only: :show
      end
    end
end
end
