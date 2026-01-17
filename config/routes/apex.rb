# frozen_string_literal: true

Rails.application.routes.draw do
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

    constraints host: ENV["APEX_SERVICE_URL"] do
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
      end
    end

    constraints host: ENV["APEX_STAFF_URL"] do
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
end
