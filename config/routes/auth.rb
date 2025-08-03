Rails.application.routes.draw do
  scope module: :auth, as: :auth do
    # service page
    constraints host: ENV["AUTH_SERVICE_URL"] do
      scope module: :app, as: :app do
        # endpoint of health check
        resource :health, only: :show
        # Sign up pages
        resource :registration, only: :new
        namespace :registration do
          resources :emails, only: %i[new create edit update]
          resources :telephones, only: %i[new create edit update]
          resource :apple, only: %i[new create]
          resource :google, only: %i[new create]
        end
        # Sign In/Out pages
        resource :authentication, only: %i[new edit destroy]
        namespace :authentication do
          resource :email, only: %i[new create]
          resource :telephone, only: %i[new create]
          resource :passkey, only: %i[new create]
          resource :recovery, only: %i[new create]
          resource :google, only: %i[new create]
          resource :apple, only: %i[new create]
        end
        # Withdrawal
        resource :withdrawal, only: %i[new create edit update]
        # Settings with logined user
        resource :setting, only: %i[show]
        namespace :setting do
          resources :passkeys, only: [ :index, :edit, :update, :new ]
          resources :recoveries
          resources :totps, only: [ :index, :new, :create, :edit, :update, :show, :destroy ]
          resources :telephones
          resources :emails
        end
      end
    end

    # For Staff's webpages auth.org.localhost
    constraints host: ENV["AUTH_STAFF_URL"] do
      scope module: :org, as: :org do
        # health check for html
        resource :health, only: :show
        # registration staff page
        resource :registration, only: [ :new, :create, :edit, :update ] do
          resource :emails, only: [ :new, :create, :edit, :update ]
          resource :telephone, only: [ :new, :create, :edit, :update ]
        end
        # Sign up pages
        resource :authentication, only: :new do
          resources :emails, only: %i[create edit update]
        end
        namespace :setting do
          resources :totp, only: [ :index, :new, :create, :edit, :update ]
          resources :passkeys, only: [ :index, :edit, :update, :new ]
          resources :emails, only: [ :index ]
          resources :apples, only: [ :show ]
          resources :googles, only: [ :show ]
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
