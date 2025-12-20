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
        end
        # Sign up pages
        resource :registration, only: :new
        namespace :registration do
          resources :emails, only: %i[new create edit update]
          resources :telephones, only: %i[new create edit update]
        end
        # Sign In/Out pages
        resource :authentication, only: %i[new edit destroy]
        namespace :authentication do
          resource :email, only: %i[new create edit update]
          resource :telephone, only: %i[new create]
        end
        # Social SignUp or LogIn
        namespace :social do
          get "apple/callback", to: "sessions#create", defaults: { provider: "apple" }
          get "google/callback", to: "sessions#create", defaults: { provider: "google_oauth2" }
        end
        # Settings with logined user
        resource :setting, only: %i[show]
        namespace :setting do
          post "passkeys/challenge", to: "passkeys#challenge", as: :sign_app_setting_passkeys_challenge
          post "passkeys/verify", to: "passkeys#verify", as: :sign_app_setting_passkeys_verify
          resources :passkeys, only: %i[index show new create edit update destroy] do
            collection do
              post :challenge
              post :verify
            end
          end
          # TODO: Implement TOTP settings management
          resources :totps, only: [ :index, :new, :create, :edit ]
          resources :recoveries, only: %i[index new create show edit update destroy]
          # TODO: Implement telephone settings management
          # resources :telephones
          # TODO: Implement email settings management
          # resources :emails
          # sign in with ***
          resource :apple, only: [ :show ]
          resource :google, only: [ :show ]
          # TODO : Implement recovery code management
          resources :secrets
        end
        # Token refresh endpoint for JSON API clients (SPA, Mobile apps)
        namespace :token do
          resource :refresh, only: :create
        end
        # Sign out
        resource :exit, only: [ :edit, :destroy ]
        # Withdrawal
        resource :withdrawal, except: :show
      end
    end

    # For Staff's webpages sign.org.localhost
    constraints host: ENV["SIGN_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # Login
        resource :authentication, only: [ :new, :destroy ]
        resource :setting, only: [ :show ]
        namespace :setting do
          # TODO: Implement TOTP settings (index, new, edit, update actions only)
          # resources :totp, only: [ :index, :new, :create, :edit, :update ]
          resources :passkeys, only: [ :index, :edit, :update, :new ]
          # TODO: Implement email settings index
          # resources :emails, only: [ :index ]
          resources :secrets
        end
        # Token refresh endpoint for JSON API clients (SPA, Mobile apps)
        namespace :token do
          resource :refresh, only: :create
        end
        # Sign out
        resource :exit, only: [ :edit, :destroy ]
        # TODO: Implement owner management
        # resources :owner
        # TODO: Implement customer management
        # resources :customer
        # TODO: Implement docs management
        # resources :docs
        # TODO: Implement news management
        # resources :news
        # TODO: Implement WWW docs creation
        # namespace :top do
        #   namespace :com do
        #     resources :docs, only: %i[new]
        #   end
        #   namespace :app do
        #     resources :docs, only: %i[new]
        #   end
        #   namespace :org do
        #     resources :docs, only: %i[new]
        #   end
        # end
      end
    end
  end
end
