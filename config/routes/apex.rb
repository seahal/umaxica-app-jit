Rails.application.routes.draw do
  scope module: :apex, as: :apex do
    constraints host: ENV["APEX_CORPORATE_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # preferences
        resource :preference, only: [ :show ]
        resource :privacy, only: [ :show ]
        namespace :privacy do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
        end
        namespace :preference do
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # for lx and tz settings.
          resource :locale, only: [ :edit, :update ]
          # for dark/light mode
          resource :theme, only: [ :edit, :update ]
          # endpoint of reset preferences.
          resource :reset, only: [ :edit, :destroy ]
        end
      end
    end

    constraints host: ENV["APEX_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # endpoint of health check
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # preferences
        resource :preference, only: [ :show ]
        namespace :preference do
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # for dark/light mode
          resource :theme, only: [ :edit, :update ]
          # for lx and tz settings.
          resource :locale, only: [ :edit, :update ]
          # endpoint of reset preferences.
          resource :reset, only: [ :edit, :destroy ]
        end
        resource :privacy, only: [ :show ]
        namespace :privacy do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
        end
        resource :configuration, only: [ :show ]
        namespace :configuration do
          # non-login user's email settings.
          resources :emails, only: [ :edit, :update, :new, :create ]
        end
      end
    end

    constraints host: ENV["APEX_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # preferences
        resource :preference, only: [ :show ]
        namespace :preference do
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # for dark/light mode
          resource :theme, only: [ :edit, :update ]
          # for lx and tz settings.
          resource :locale, only: [ :edit, :update ]
          # endpoint of reset preferences.
          resource :reset, only: [ :edit, :destroy ]
        end
        resource :privacy, only: [ :show ]
        namespace :privacy do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
        end
      end
    end
  end
end
