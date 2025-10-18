Rails.application.routes.draw do
  scope module: :auth, as: :auth do
    # service page
    constraints host: ENV["AUTH_SERVICE_URL"] do
      scope module: :app, as: :app do
        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }
        # Sign up pages
        resource :registration, only: :new
        namespace :registration do
          resources :emails, only: %i[new create edit update]
          resources :telephones, only: %i[new create edit update]
          resources :apples, only: %i[new]
          resources :googles, only: %i[new]
        end
        # Sign In/Out pages
        resource :authentication, only: %i[new edit destroy]
        namespace :authentication do
          resource :email, only: %i[new create]
          resource :telephone, only: %i[new create]
          resource :passkey, only: %i[new create]
          resource :recovery, only: %i[new create]
          # TODO(human): Refactor OAuth flow to use only GET requests for better security
          # Change from POST create to GET show to eliminate CSRF protection bypass
          resource :apple, only: %i[new create]
          resource :google, only: %i[new]
        end
        # OAuth required pages
        get "auth/:provider/callback", to: "sessions#create"
        get "auth/failure", to: redirect("/") # TODO: Fix this
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
          resources :recoveries
          resources :totps
          resources :telephones
          resources :emails
          resource :apple, only: [ :show ]
          resource :google, only: [ :show ]
        end
        namespace :token do
          resources :refreshs, only: [ :update ]
        end
      end
    end

    # For Staff's webpages auth.org.localhost
    constraints host: ENV["AUTH_STAFF_URL"] do
      scope module: :org, as: :org do
        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }
        # registration staff page
        resource :registration, only: [ :new, :create, :edit, :update ] do
          resource :emails, only: [ :new, :create, :edit, :update ]
          resource :telephone, only: [ :new, :create, :edit, :update ]
        end
        # Sign up pages
        resource :authentication
        namespace :setting do
          resources :totp, only: [ :index, :new, :create, :edit, :update ]
          resources :passkeys, only: [ :index, :edit, :update, :new ] do
            collection do
              post :challenge
              post :verify
            end
          end
          resources :emails, only: [ :index ]
        end
        #
        resource :withdrawal, only: %i[new create edit update]
        # for owner
        resources :owner
        # for customer services
        resources :customer
        # docs
        resources :docs
        # news
        resources :news
        # OAuth required pages
        namespace :www do
          namespace :com do
            resources :docs, only: %i[new]
          end
          namespace :app do
            resources :docs, only: %i[new]
          end
          namespace :org do
            resources :docs, only: %i[new]
          end
        end
      end
    end
  end
end
