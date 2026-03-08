# typed: false
# frozen_string_literal: true

scope module: :help, as: :help do
  constraints host: ENV["HELP_CORPORATE_URL"] do
    scope module: :com, as: :com do
      root to: "roots#index"
      # health check for html/json
      resource :health, only: :show
      resource :sitemap, only: :show, defaults: { format: :xml }
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v1 do
          resource :health, only: :show
          resource :sitemap, only: :show
        end
      end
    end
  end

  constraints host: ENV["HELP_SERVICE_URL"] do
    scope module: :app, as: :app do
      root to: "roots#index"
      # health check for html/json
      resource :health, only: :show
      resource :sitemap, only: :show, defaults: { format: :xml }
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v1 do
          resource :health, only: :show
          resource :sitemap, only: :show
        end
      end
    end
  end

  constraints host: ENV["HELP_STAFF_URL"] do
    scope module: :org, as: :org do
      root to: "roots#index"
      # health check for html/json
      resource :health, only: :show
      resource :sitemap, only: :show, defaults: { format: :xml }
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v1 do
          resource :health, only: :show
          resource :sitemap, only: :show
        end
      end
    end
  end
end
