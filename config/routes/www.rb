Rails.application.routes.draw do
  scope module: :www, as: :www do
    # for client site
    constraints host: ENV["WWW_CORPORATE_URL"] do
      scope module: :com, as: :com do
        # health check for html
        resource :health, only: :show, format: :html
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
      end
    end

    # service page
    constraints host: ENV["WWW_SERVICE_URL"] do
      scope module: :app, as: :app do
        # endpoint of health check
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
      end
    end

    # For Staff's webpages www.jp.example.org
    constraints host: ENV["WWW_STAFF_URL"] do
      # mount Karafka::Web::App, at: "/karafka"

      scope module: :org, as: :org do
        # health check for html
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
      end
    end
  end
end
