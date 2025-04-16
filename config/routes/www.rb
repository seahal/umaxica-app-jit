Rails.application.routes.draw do
  scope module: :www, as: :www do
    constraints host: ENV["WWW_CORPORATE_URL"] do
      scope module: :com, as: :com do
        #
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
        # show stating env
        resource :staging, only: :show, format: :html
        # for ePrivacy settings.
        resource :cookie, only: [ :edit, :update ]
        # show search pages
        resource :search, only: :show
        # contact page
        resources :contacts, only: :new do
          resource :telephone, only: :show
          resource :email, only: :show
        end
        resource :preference, only: [ :show ] do
          resource :privacy, only: [ :edit, :update ]
          resources :emails, only: [ :index ]
        end
      end

      constraints host: ENV["WWW_SERVICE_URL"] do
        scope module: :app, as: :app do
          # homepage
          root to: "roots#index"
          # root to: "roots#index"
          resource :health, only: :show
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # show stating env
          resource :staging, only: :show
          # Sign up pages
          resource :registration, only: :new
          namespace :registration do
              resources :emails, only: %i[new create edit update show]
              resources :telephones, only: %i[new create edit update]
              resource :google, only: %i[new create]
              resource :apple, only: %i[new create]
          end
          # Withdrawal
          resource :withdrawal, only: %i[edit destroy] # TODO: Create or Delete membership
          # Sign In/Out, NEED WEB
          resource :session, only: %i[new destroy]
          namespace :session do
            resource :email, only: %i[new create]
            resource :telephone, only: %i[new create]
            resource :google, only: %i[new create]
            resource :apple, only: %i[new create]
            resource :passkey, only: %i[new create]
            resource :password, only: %i[new create]
          end
          # Settings without login
          resource :preference, only: [ :show ] do
            resource :privacy, only: [ :edit, :update ]
            resources :emails, only: [ :index ]
          end
        end
      end
    end
  # For Staff's webpages www.jp.example.org
  constraints host: ENV["WWW_STAFF_URL"] do
    scope module: :org, as: :org do
      # Homepage
      root to: "roots#index"
      # health check for html
      resource :health, only: :show
      # for ePrivacy settings.
      resource :cookie, only: [ :edit, :update ]
      # show stating env
      resource :staging, only: :show, format: :html
      # non-loggined settings
      resource :privacy, only: [ :show, :edit ]
      # contact page
      namespace :contact do
      end
      # TODO: Owner's lounge
      resource :owner, only: :show
      # Sign up pages
      # todo: rewrite namespace
      resource :registration, only: :new, shallow: true do
        resources :emails, only: %i[create edit update]
      end
      # TODO: Login or Logout
      resource :session, only: :new, shallow: true do
        resource :email, only: %i[new create]
      end
      # Settings without login
      resource :preference, only: [ :show ] do
        resource :privacy, only: [ :edit, :update ]
      end
      # for owner
      resources :owner
      # for customer services
      resources :customer
      # docs
      resources :docs
      # news
      resources :news
    end
  end
    end
end
