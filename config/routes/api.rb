Rails.application.routes.draw do
  scope module: :api, as: :api do
    constraints host: ENV["API_CORPORATE_URL"] do
      scope module: :com, as: :com do
        namespace :v0 do
          resource :staging, only: :show, format: "json"
          resource :docs, only: :show
          resource :news, only: :show
        end
        namespace :v1 do
          resource :health, only: :show
          resource :version, only: :show
          resource :status, only: :show
        end
      end
    end

    constraints host: ENV["API_SERVICE_URL"] do
      scope module: :app, as: :app do
        namespace :v0 do
          resource :staging, only: :show, format: "json"
          resource :docs, only: :show
          resource :news, only: :show
        end
        namespace :v1 do
          resource :health, only: :show
          resource :version, only: :show
          resource :status, only: :show
          namespace :beacon do
            resources :emails, only: %i[show]
          end
          namespace :persona do
            resources :avators
          end
        end
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints host: ENV["API_STAFF_URL"] do
      scope module: :org, as: :org do
        namespace :v0 do
          resource :staging, only: :show, format: "json"
          resource :docs, only: :show
          resource :news, only: :show
        end
        namespace :v1 do
          resource :health, only: :show
          resource :version, only: :show
          resource :status, only: :show
        end
      end
    end
  end
end
