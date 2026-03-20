# typed: false
# frozen_string_literal: true

scope module: :help, as: :help do
  constraints host: ENV["HELP_CORPORATE_URL"] do
    scope module: :com, as: :com do
      root to: "roots#index"
      # health check for html/json
      resource :health, only: :show
      resource :sitemap, only: :show, defaults: { format: :xml }
      namespace :web do
        namespace :v0 do
          resource :cookie, only: %i(show update)
          resource :theme, only: %i(show update)
        end
      end
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v0 do
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
      namespace :web do
        namespace :v0 do
          resource :cookie, only: %i(show update)
          resource :theme, only: %i(show update)
        end
      end
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v0 do
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
      namespace :web do
        namespace :v0 do
          resource :cookie, only: %i(show update)
          resource :theme, only: %i(show update)
        end
      end
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v0 do
          resource :health, only: :show
          resource :sitemap, only: :show
        end
      end
    end
  end
end
