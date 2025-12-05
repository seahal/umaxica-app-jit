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
          # TODO: Implement Apple Sign-in registration
          # resources :apples, only: %i[new]
        end
        # Sign In/Out pages
        resource :authentication, only: %i[new edit destroy]
        namespace :authentication do
          resource :email, only: %i[new create]
          resource :telephone, only: %i[new create]
          # TODO(human): Refactor OAuth flow to use only GET requests for better security
          # Change from POST create to GET show to eliminate CSRF protection bypass
          resource :apple, only: %i[new create]
          resource :google, only: %i[new]
        end
        # Social SignUp or LogIn
        namespace :oauth do
          get "apple/callback", to: "apples#callback", as: "apple_callback"
          get "google/callback", to: "googles#callback", as: "google_callback"
          get "google_oauth2/callback", to: "googles#callback", as: "google_oauth2_callback"
          resource :apple, only: [ :create ] do
            get :callback
            get :failure
          end
          resource :google, only: [ :create ] do
            get :callback
            get :failure
          end
        end
        get "/auth/google/callback", to: "oauth/googles#callback"
        get "/auth/apple/callback", to: "oauth/apples#callback"
        get "/auth/failure", to: "oauth/apples#failure"
        # Withdrawal
        resource :withdrawal, only: %i[new create edit update]
        # Settings with logined user
        resource :setting, only: %i[show]
        namespace :setting do
          resources :passkeys, only: [ :index, :edit, :update, :new ] do
            collection do
              post :challenge
              post :verify
            end
          end
          # TODO: Implement TOTP settings management
          resources :totps, only: [ :index, :new, :create, :edit ]
          # TODO: Implement telephone settings management
          # resources :telephones
          # TODO: Implement email settings management
          # resources :emails
          resource :apple, only: [ :show ]
          resource :google, only: [ :show ]
          # TODO : Implement recovery code management
          resources :secrets
        end
        # TODO: Implement token refresh functionality
        # namespace :token do
        #   resources :refreshs, only: [ :update ]
        # end
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
        # registration staff page
        # 変更後（sign/app と同じパターン）
        resource :registration, only: [ :new ]
        namespace :registration do
          resources :emails, only: %i[new create edit update]
          resources :telephones, only: %i[new create edit update]
        end
        # Sign up pages
        # TODO: Implement authentication actions (show, update, put, delete, create)
        resource :authentication, only: [ :new ]
        namespace :setting do
          # TODO: Implement TOTP settings (index, new, edit, update actions only)
          # resources :totp, only: [ :index, :new, :create, :edit, :update ]
          resources :passkeys, only: [ :index, :edit, :update, :new ]
          # TODO: Implement email settings index
          # resources :emails, only: [ :index ]
          resources :secrets
        end
        #
        resource :withdrawal, only: %i[new create edit update]
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
