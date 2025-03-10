Rails.application.routes.draw do
  scope module: :api, as: :api do
    constraints host: ENV["API_CORPORATE_URL"] do
      scope module: :com, as: :com do
        namespace :v1 do
          resource :staging, only: :show
          resource :health, only: :show
          resource :version, only: :show
          resource :metric, only: :show
          resource :debug, only: :show
          resource :status, only: :show
        end
        # ROBOTS
        resources :robots, only: :index, format: :txt
        # Security
        get "/security(.:format)", to: redirect("https://#{ENV['EDGE_CORPORATE_URL']}/security.html"), as: :security
      end
    end

    constraints host: ENV["API_SERVICE_URL"] do
      scope module: :net, as: :net do
        namespace :v1 do
          resource :staging, only: :show
          resource :health, only: :show
          resource :version, only: :show
          resource :metric, only: :show
          resource :debug, only: :show
          resource :status, only: :show
          #
          namespace :beacon do
            resources :emails, only: %i[show]
          end
        end
        # ROBOTS
        resources :robots, only: :index, format: :txt
        # Security
        get "/security(.:format)", to: redirect("#{ENV['EDGE_SERVICE_URL']}/security.html"), as: :security
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints host: ENV["API_STAFF_URL"] do
      scope module: :org, as: :org do
        #
        namespace :v1 do
          resource :staging, only: :show
          resource :health, only: :show
          resource :version, only: :show
          resource :metric, only: :show
          resource :debug, only: :show
          resource :status, only: :show
        end
        # robots
        resources :robots, only: :index, format: :txt
        # Security
        get "/security(.:format)", to: redirect("#{ENV['EDGE_STAFF_URL']}/security.html"), as: :security
      end
    end
  end
end
