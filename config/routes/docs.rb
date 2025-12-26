Rails.application.routes.draw do
  scope module: :docs, as: :docs do
    constraints host: ENV["DOCS_CORPORATE_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        resource :find, only: [:show], controller: "find"
        resource :post, only: [:show], controller: "post"
      end
    end

    constraints host: ENV["DOCS_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        resource :find, only: [:show], controller: "find"
        resource :post, only: [:show], controller: "post"
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints host: ENV["DOCS_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        resource :find, only: [:show], controller: "find"
        resource :post, only: [:show], controller: "post"
      end
    end
  end
end
