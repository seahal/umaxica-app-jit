Rails.application.routes.draw do
  scope module: :www, as: :www do
    # for client site
    constraints host: ENV["WWW_CORPORATE_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
        # show stating env
        resource :staging, only: :show, format: :html
        # settings
        resource :preference, only: [ :show ]
        namespace :preference do
          resource :cookie, only: [ :edit, :update ]
        end
      end

      # service page
      constraints host: ENV["WWW_SERVICE_URL"] do
        scope module: :app, as: :app do
          root to: "roots#index"
          # endpoint of health check
          resource :health, only: :show
          # show stating env
          resource :staging, only: :show
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
        root to: "roots#index"

        # health check for html
        resource :health, only: :show
        # show stating env
        resource :staging, only: :show, format: :html
        # Settings without login
        resource :preference, only: [ :show ]
        namespace :preference do
          resource :cookie, only: [ :edit, :update ]
          resources :emails, only: [ :create, :new ]
          resources :telephones, only: [ :create, :new ]
        end
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
