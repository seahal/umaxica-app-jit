# frozen_string_literal: true

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
      resource :client, only: :show

      # Sign up
      resource :up, only: :new
      namespace :up do
        # TODO: implement 2fa at show and update methods
        resources :emails, only: %i(new create edit update show destroy)
        resources :telephones, only: %i(new create edit update show destroy)
      end

      # Sign in/out
      resource :in, only: %i(new)
      namespace :in do
        # TODO: added show delete methods for 2FA
        resource :email, only: %i(new create edit update) do
          resource :session, only: %i(edit update)
        end
        # Passkey authentication for sign-in
        # GET  /in/passkeys/new          -> new (login page with passkey button)
        # POST /in/passkeys/options      -> options for authentication challenge
        # POST /in/passkeys/verification -> verify authentication response
        resources :passkeys, only: [:new] do
          resource :session, only: %i(edit update)
          # TODO: fix them and merget to passkeys.
          collection do
            post :options
            post :verification
          end
        end
        resource :secret, only: %i(new create) do
          resource :session, only: %i(edit update)
        end
      end

      # ==========================================================================
      # Social Authentication (OmniAuth)
      # ==========================================================================
      # Standard OmniAuth paths:
      #   Start:    POST /auth/:provider (handled by OmniAuth middleware)
      #   Callback: GET/POST /auth/:provider/callback
      #   Failure:  GET/POST /auth/failure
      #
      # Our custom entry point:
      #   GET /social/start?provider=...&intent=... -> prepares intent, redirects to /auth/:provider
      # ==========================================================================

      # Entry point for social auth with intent management
      namespace :social do
        # GET /social/start?provider=google_oauth2&intent=login|link|reauth
        # Prepares session with intent/state, then redirects to /auth/:provider
        get "start", to: "sessions#start"

        # Unlink social identity (requires auth)
        # DELETE /social/:provider/unlink
        delete ":provider/unlink",
               to: "sessions#unlink",
               as: :unlink,
               constraints: { provider: /google_oauth2|apple/ }
      end

      # OmniAuth standard callbacks (mounted at /auth/*)
      namespace :auth, path: "auth" do
        # OmniAuth callbacks - both GET (Google) and POST (Apple)
        # GET/POST /auth/:provider/callback
        match ":provider/callback",
              to: "omniauth_callbacks#omniauth",
              via: %i(get post),
              as: :callback

        # OmniAuth failure callback
        # GET/POST /auth/failure
        match "failure",
              to: "omniauth_callbacks#failure",
              via: %i(get post)
      end

      resources :reauth, only: %i(index show new create edit update destroy)

      # Settings with logged-in user
      resource :configuration, only: :show
      namespace :configuration do
        # TODO: Implement TOTP settings management
        resources :totps, only: %i(index new create edit update destroy)

        # Passkey management (CRUD-based)
        # GET    /configuration/passkeys           -> index
        # GET    /configuration/passkeys/new       -> new (registration form)
        # POST   /configuration/passkeys           -> create
        # GET    /configuration/passkeys/:id       -> show
        # GET    /configuration/passkeys/:id/edit  -> edit
        # PATCH  /configuration/passkeys/:id       -> update
        # DELETE /configuration/passkeys/:id       -> destroy
        # POST   /configuration/passkeys/options      -> WebAuthn registration options
        # POST   /configuration/passkeys/verification -> WebAuthn registration verification
        resources :passkeys do
          collection do
            post :options
            post :verification
          end
        end

        resources :emails
        resources :telephones
        resource :apple, only: [:show, :destroy]
        resource :google, only: %i(show update destroy)
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
        # Passkey authentication for sign-in
        # GET  /in/passkeys/new          -> new (login page with passkey button)
        # POST /in/passkeys/options      -> options for authentication challenge
        # POST /in/passkeys/verification -> verify authentication response
        resources :passkeys, only: [:new] do
          collection do
            post :options
            post :verification
          end
          resource :session, only: %i(edit update)
        end
        resource :secret, only: %i(new create) do
          resource :session, only: %i(edit update)
        end
      end

      resources :reauth, only: %i(index show new create edit update destroy)

      # Settings
      resource :configuration, only: :show
      namespace :configuration do
        resources :totps, only: %i(index new create edit update destroy)

        # TODO: Passkey management (CRUD-based)
        resources :passkeys do
          collection do
            post :options
            post :verification
          end
        end

        resources :secrets
        resources :sessions
        resource :withdrawal, only: %i(show)
      end

      # Sign out
      resource :out, only: %i(edit destroy)
    end
  end
end
