Rails.application.routes.draw do
  scope module: :api, as: :api do
    constraints host: ENV["API_CORPORATE_URL"] do
      scope module: :com, as: :com do
        # health check for html
        resource :health, only: :show
        # version
        namespace :v1 do
          resource :staging, only: :show, defaults: { format: :json }
          resource :version, only: :show
          resource :status, only: :show
        end
      end
    end

    constraints host: ENV["API_SERVICE_URL"] do
      scope module: :app, as: :app do
        # health check for html
        resource :health, only: :show
        # version
        namespace :v1 do
          resource :staging, only: :show, defaults: { format: :json }
          resource :status, only: :show
          namespace :beacon do
            resources :emails, only: %i[show]
          end
          namespace :persona do
            resources :avatars
          end
          namespace :inquiry do
            resources :valid_email_addresses, only: %i[show]
            resources :valid_telephone_numbers, only: %i[create]
          end
        end
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints host: ENV["API_STAFF_URL"] do
      scope module: :org, as: :org do
        # health check for html
        resource :health, only: :show
        # version
        namespace :v1 do
          resource :staging, only: :show, defaults: { format: :json }
          resource :version, only: :show
          resource :status, only: :show
        end
      end
    end
  end
end
