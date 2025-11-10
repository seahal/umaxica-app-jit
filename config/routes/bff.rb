Rails.application.routes.draw do
  scope module: :bff, as: :bff do
    # for client site
    constraints host: ENV["BFF_CORPORATE_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
      end
    end

    # service page
    constraints host: ENV["BFF_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # endpoint of health check
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # preferences
        resource :preference, only: [ :show ]
        namespace :preference do
          # non-login user's email settings.
          resources :emails, only: [ :edit, :update, :new, :create ]
        end
      end
    end

    # For Staff's webpages bff.jp.example.org
    constraints host: ENV["BFF_STAFF_URL"] do
      # mount Karafka::Web::App, at: "/karafka"

      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # preferences
        resource :preference, only: [ :show ]
        namespace :preference do
          # non-login user's email settings.
          resources :emails, only: [ :edit, :update, :new, :create ]
        end
      end
    end
  end
end
