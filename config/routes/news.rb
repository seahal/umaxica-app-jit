Rails.application.routes.draw do
  scope module: :api, as: :api do
    constraints host: ENV["NEWS_CORPORATE_URL"] do
      scope module: :com, as: :com do
      end
    end

    constraints host: ENV["NEWS_SERVICE_URL"] do
      scope module: :app, as: :app do
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints host: ENV["NEWS_STAFF_URL"] do
      scope module: :org, as: :org do
      end
    end
  end
end
