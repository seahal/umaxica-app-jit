# typed: false
# frozen_string_literal: true

scope module: :apex, as: :apex do
  constraints host: ENV["APEX_CORPORATE_URL"] do
    scope module: :com, as: :com do
      root to: "roots#index"
      # health check for html
      resource :health, only: :show, format: :html
      resource :sitemap, only: :show, defaults: { format: :xml }
      # Edge API endpoint (browser/Rails view)
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
          resource :cookie, only: %i(show update)
          resource :dbsc, only: :create
        end
      end
      # OIDC callback
      namespace :auth do
        resource :callback, only: :show
      end
    end
  end

  # FIXME: what is this?
  constraints lambda { |request|
                request.host == ENV["APEX_SERVICE_URL"] && Core::Surface.matches?(request, :app)
              } do
    scope module: :app, as: :app do
      root to: "roots#index"

      # endpoint of health check
      resource :health, only: :show
      resource :sitemap, only: :show, defaults: { format: :xml }

      # OIDC callback
      namespace :auth do
        resource :callback, only: :show
      end

      # Edge API endpoint (browser/Rails view)
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
          resource :cookie, only: %i(show update)
          resource :dbsc, only: :create
        end
      end
      resource :configuration, only: [:show]
      namespace :configuration do
        # logged in user's email settings.
        resources :emails, only: %i(edit update new create)
      end
      # for emergency token operations
      namespace :emergency do
        namespace :app do
          resource :token, only: %i(show update)
        end
      end
    end
  end

  # FIXME: what is this?
  constraints lambda { |request|
                request.host == ENV["APEX_STAFF_URL"] && Core::Surface.matches?(request, :org)
              } do
    scope module: :org, as: :org do
      root to: "roots#index"
      # OIDC callback
      namespace :auth do
        resource :callback, only: :show
      end
      # health check for html
      resource :health, only: :show, format: :html
      # Edge API endpoint (browser/Rails view)
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
          resource :cookie, only: %i(show update)
          resource :dbsc, only: :create
        end
      end
      # for emergency
      namespace :emergency do
        namespace :app do
          resource :token, only: %i(show update)
          resource :cache, only: %i(show update destroy)
        end
        namespace :com do
          resource :token, only: %i(show update)
          resource :cache, only: %i(show update destroy)
        end
        namespace :org do
          resource :cache, only: %i(show update destroy)
        end
      end

      resource :configuration, only: [:show]
      namespace :configuration do
        # logged in user's email settings.
        resources :emails, only: %i(edit update new create)
      end
    end
  end
end
