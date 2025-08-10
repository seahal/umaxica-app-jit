Rails.application.routes.draw do
  scope module: :apex, as: :apex do
    # for corporate site
    constraints host: ENV["WWW_CORPORATE_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
        # settings
        resource :preference, only: [ :show ]
        namespace :preference do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # timezone configuration
          resource :timezone, only: [ :edit, :update ]
          # language preferences
          resource :language, only: [ :edit, :update ]
          # email preferences
          resource :email, only: [ :edit, :update ]
          # theme/dark mode settings
          resource :theme, only: [ :edit, :update ]
        end
        # Basic resources
        resource :staging, only: [ :show ]
      end
    end

    # service page
    constraints host: ENV["WWW_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # endpoint of health check
        resource :health, only: :show
        # Settings without login
        resource :preference, only: %i[show]
        namespace :preference do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # timezone configuration
          resource :timezone, only: [ :edit, :update ]
          # language preferences
          resource :language, only: [ :edit, :update ]
          # email preferences
          resource :email, only: [ :edit, :update ]
          # theme/dark mode settings
          resource :theme, only: [ :edit, :update ]
        end
      end
    end

    # For Staff's webpages example.org
    constraints host: ENV["WWW_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show
        # Settings without login
        resource :preference, only: [ :show ]
        namespace :preference do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # timezone configuration
          resource :timezone, only: [ :edit, :update ]
          # language preferences
          resource :language, only: [ :edit, :update ]
          # email preferences
          resource :email, only: [ :edit, :update ]
          # theme/dark mode settings
          resource :theme, only: [ :edit, :update ]
        end
      end
    end
  end
end
