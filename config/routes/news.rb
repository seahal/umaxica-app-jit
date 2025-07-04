Rails.application.routes.draw do
  scope module: :news, as: :news do
    constraints host: ENV["NEWS_CORPORATE_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
      end
    end

    constraints host: ENV["NEWS_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints host: ENV["NEWS_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
      end
    end
  end
end
