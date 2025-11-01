Rails.application.routes.draw do
  scope module: :root, as: :root do
    # for corporate site
    constraints host: ENV["APEX_CORPORATE_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # settings
        resource :preference, only: [ :show ]
        namespace :preference do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # for dark/light mode
          resource :theme, only: [ :edit, :update ]
          # Clear all preference cookies
          resource :reset, only: [ :edit, :destroy ]
        end
      end
    end

    # service page
    constraints host: ENV["APEX_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # Settings without login
        resource :preference, only: %i[show]
        namespace :preference do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # for dark/light mode
          resource :theme, only: [ :edit, :update ]
          # Clear all preference cookies
          resource :reset, only: [ :edit, :destroy ]
        end
      end
    end

    # For Staff's webpages example.org
    constraints host: ENV["APEX_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show, defaults: { format: :html }
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # Settings without login
        resource :preference, only: [ :show ]
        namespace :preference do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # for dark/light mode
          resource :theme, only: [ :edit, :update ]
          # Clear all preference cookies
          resource :reset, only: [ :edit, :destroy ]
        end
      end
    end
  end
end
