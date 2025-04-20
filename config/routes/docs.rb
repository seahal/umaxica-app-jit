Rails.application.routes.draw do
  scope module: :docs, as: :docs do
    constraints host: ENV["DOCS_CORPORATE_URL"] do
      scope module: :com, as: :com do
        #
        root to: "roots#index"
      end
    end

    constraints host: ENV["DOCS_SERVICE_URL"] do
      scope module: :app, as: :app do
        #
        root to: "roots#index"
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints host: ENV["DOCS_STAFF_URL"] do
      scope module: :org, as: :org do
        #
        root to: "roots#index"
      end
    end
  end
end
