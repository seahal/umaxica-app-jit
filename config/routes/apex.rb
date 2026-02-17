# frozen_string_literal: true

scope module: :apex, as: :apex do
  constraints host: ENV["APEX_CORPORATE_URL"] do
    scope module: :com, as: :com do
      root to: "roots#index"
      # health check for html
      resource :health, only: :show, format: :html
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v1 do
          resource :csrf, only: :show
          resource :health, only: :show
        end
      end
      # preferences
      resource :preference, only: [:show]
      namespace :preference do
        # for region settings.
        resource :region, only: [:edit, :update]
        namespace :region do
          # for lx and tz settings.
          resource :timezone, only: [:edit, :update]
          resource :language, only: [:edit, :update]
        end
        # for dark/light mode
        resource :theme, only: [:edit, :update]
        # endpoint of reset preferences.
        resource :reset, only: [:edit, :destroy]
        # for ePrivacy settings.
        resource :cookie, only: [:edit, :update]
      end
      resource :configuration, only: [:show]
      namespace :configuration do
        # logged in user's email settings.
        resources :emails, only: %i(edit update new create)
      end
    end
  end

  constraints lambda { |request|
                request.host == ENV["APEX_SERVICE_URL"] && Core::Surface.matches?(request, :app)
              } do
    scope module: :app, as: :app do
      root to: "roots#index"
      # endpoint of health check
      resource :health, only: :show
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v1 do
          resource :csrf, only: :show
          resource :health, only: :show
        end
      end
      # preferences
      resource :preference, only: [:show]
      namespace :preference do
        # for region settings.
        resource :region, only: [:edit, :update]
        namespace :region do
          # for lx and tz settings.
          resource :timezone, only: [:edit, :update]
          resource :language, only: [:edit, :update]
        end
        # for dark/light mode
        resource :theme, only: [:edit, :update]
        # for ePrivacy settings.
        resource :cookie, only: [:edit, :update]
        # endpoint of reset preferences.
        resource :reset, only: [:edit, :destroy]
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

  constraints lambda { |request|
                request.host == ENV["APEX_STAFF_URL"] && Core::Surface.matches?(request, :org)
              } do
    scope module: :org, as: :org do
      root to: "roots#index"
      # health check for html
      resource :csrf, only: :show
      resource :health, only: :show, format: :html
      # Edge API endpoint (browser/SPA)
      namespace :edge do
        namespace :v1 do
          resource :health, only: :show
        end
      end
      # for emergency
      namespace :emergency do
        namespace :app do
          resource :outage, only: %i(show update)
          resource :token, only: %i(show update destroy)
          resource :cache, only: %i(show update destroy)
        end
        namespace :com do
          resource :outage, only: %i(show update)
          resource :token, only: %i(show update)
          resource :cache, only: %i(show update destroy)
        end
        namespace :org do
          resource :outage, only: %i(show update)
          resource :token, only: %i(show update destroy)
          resource :cache, only: %i(show update destroy)
        end
      end
      namespace :status do
        namespace :app do
        end
        resource :app, only: :show
        namespace :com do
        end
        resource :com, only: :show

        namespace :org do
        end
        resource :org, only: :show
      end
      # preferences
      resource :preference, only: [:show]
      namespace :preference do
        # for region settings.
        resource :region, only: [:edit, :update]
        namespace :region do
          # for lx and tz settings.
          resource :timezone, only: [:edit, :update]
          resource :language, only: [:edit, :update]
        end
        # for dark/light mode
        resource :theme, only: [:edit, :update]
        # endpoint of reset preferences.
        resource :reset, only: [:edit, :destroy]
        # for ePrivacy settings.
        resource :cookie, only: [:edit, :update]
      end
      resource :configuration, only: [:show]
      namespace :configuration do
        # logged in user's email settings.
        resources :emails, only: %i(edit update new create)
      end
    end
  end
end
