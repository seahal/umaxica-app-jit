# typed: false
# frozen_string_literal: true

scope module: :docs, as: :docs do
  constraints host: ENV["DOCS_CORPORATE_URL"] do
    scope module: :com, as: :com do
      root to: "roots#index"
      # health check for html/json
      resource :health, only: :show
      resource :sitemap, only: :show, defaults: { format: :xml }
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v1, defaults: { format: :json } do
          resource :health, only: :show
          resource :sitemap, only: :show
          resources :posts, only: [:index, :show] do
            resources :versions, only: [:index, :show]
          end
          resources :tags, only: :index
          resources :categories, only: :index
        end
      end
    end
  end

  constraints host: ENV["DOCS_SERVICE_URL"] do
    scope module: :app, as: :app do
      root to: "roots#index"
      # health check for html/json
      resource :health, only: :show
      resource :sitemap, only: :show, defaults: { format: :xml }
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v1, defaults: { format: :json } do
          resource :health, only: :show
          resource :sitemap, only: :show
          resources :posts, only: [:index, :show] do
            resources :versions, only: [:index, :show]
          end
          resources :tags, only: :index
          resources :categories, only: :index
        end
      end
    end
  end

  # For Staff's webpages api.jp.example.org
  constraints host: ENV["DOCS_STAFF_URL"] do
    scope module: :org, as: :org do
      root to: "roots#index"
      # health check for html/json
      resource :health, only: :show
      resource :sitemap, only: :show, defaults: { format: :xml }
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v1, defaults: { format: :json } do
          resource :health, only: :show
          resource :sitemap, only: :show
          resources :posts, only: [:index, :show] do
            resources :versions, only: [:index, :show]
          end
          resources :tags, only: :index
          resources :categories, only: :index
        end
      end
    end
  end
end
