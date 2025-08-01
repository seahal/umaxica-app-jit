Rails.application.routes.draw do
  scope module: :www, as: :www do
    # for client site
    constraints host: ENV["WWW_CORPORATE_URL"] do
      scope module: :com, as: :com do
        # health check for html
        resource :health, only: :show, format: :html
        # show stating env
        resource :staging, only: :show, format: :html
        # settings
        resource :preference, only: [ :show ]
        namespace :preference do
          resource :cookie, only: [ :edit, :update ]
        end
        resource :registration, only: [ :new, :create, :edit, :update ] do
          resource :emails, only: [ :new, :create, :edit, :update ]
          resource :telephone, only: [ :new, :create, :edit, :update ]
        end
      end

      # service page
      constraints host: ENV["WWW_SERVICE_URL"] do
        scope module: :app, as: :app do
          # endpoint of health check
          resource :health, only: :show
          # show stating env
          resource :staging, only: :show
          # Withdrawal
          resource :withdrawal, only: %i[new create edit update]
          # Settings with logined user
          resource :setting, only: %i[show]
          namespace :setting do
            resources :totp, only: [ :index, :new, :create, :edit, :update ]
            resources :passkeys, only: [ :index, :edit, :update, :new ]
            resources :recovery_codes, only: %i[index new create edit update destroy show]
            resources :tokens, only: [ :show, :destroy ]
            resources :emails, only: [ :index ]
            resource :apple, only: [ :show ]
            resource :google, only: [ :show ]
          end
          # Settings without login
          resource :preference, only: %i[show]
          namespace :preference do
            # for ePrivacy settings.
            resource :cookie, only: [ :edit, :update ]
            resources :emails, only: [ :edit, :update, :new ]
            resources :telephones, only: [ :create, :new ]
          end
        end
      end
    end

    # For Staff's webpages www.jp.example.org
    constraints host: ENV["WWW_STAFF_URL"] do
      mount Karafka::Web::App, at: "/karafka"

      scope module: :org, as: :org do
        # health check for html
        resource :health, only: :show
        # show stating env
        resource :staging, only: :show, format: :html
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
        # Settings without login
        resource :preference, only: [ :show ]
        namespace :preference do
          resource :cookie, only: [ :edit, :update ]
          resources :emails, only: [ :create, :new ]
          resources :telephones, only: [ :create, :new ]
        end
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
