Rails.application.routes.draw do
  scope module: :top, as: :top do
    constraints host: ENV["TOP_CORPORATE_URL"] do
      scope module: :com, as: :com do
        # health check for html
        resource :health, only: :show, format: :html
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # preferences
        resource :preference, only: [ :show ]
        namespace :preference do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # for dark/light mode
          resource :theme, only: [ :edit, :update ]
        end
      end
    end

    constraints host: ENV["TOP_SERVICE_URL"] do
      scope module: :app, as: :app do
        # endpoint of health check
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # preferences
        resource :preference, only: [ :show ]
        namespace :preference do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # for dark/light mode
          resource :theme, only: [ :edit, :update ]
        end
      end
    end

    constraints host: ENV["TOP_STAFF_URL"] do
      scope module: :org, as: :org do
        # health check for html
        resource :health, only: :show, format: :html
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # preferences
        resource :preference, only: [ :show ]
        namespace :preference do
          # for ePrivacy settings.
          resource :cookie, only: [ :edit, :update ]
          # for region settings.
          resource :region, only: [ :edit, :update ]
          # for dark/light mode
          resource :theme, only: [ :edit, :update ]
        end
      end
    end
  end
end
