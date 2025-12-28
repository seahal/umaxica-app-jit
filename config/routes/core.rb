# frozen_string_literal: true

Rails.application.routes.draw do
  scope module: :core, as: :core do
    # for client site
    constraints host: (ENV["CORE_CORPORATE_URL"] || ENV["BACK_CORPORATE_URL"]) do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show, format: :html
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
          resource :csrf, only: :show
        end
      end
    end

    # service page
    constraints host: (ENV["CORE_SERVICE_URL"] || ENV["BACK_SERVICE_URL"]) do
      scope module: :app, as: :app do
        root to: "roots#index"
        # endpoint of health check
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
          resource :csrf, only: :show
        end
      end
    end

    # For Staff's webpages
    constraints host: (ENV["CORE_STAFF_URL"] || ENV["BACK_STAFF_URL"]) do
      # mount Karafka::Web::App, at: "/karafka"
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
          resource :csrf, only: :show
        end

        namespace :docs do
          namespace :com do
            resources :posts do
              resources :versions
            end
          end
          namespace :org do
            resources :posts do
              resources :versions
            end
          end
          namespace :app do
            resources :posts do
              resources :versions
            end
          end
        end
        namespace :news do
          namespace :com do
            resources :posts do
              resources :versions
            end
          end
          namespace :org do
            resources :posts do
              resources :versions
            end
          end
          namespace :app do
            resources :posts do
              resources :versions
            end
          end
        end
        namespace :help do
          namespace :com do
            resources :contacts
          end
          namespace :org do
            resources :contacts
          end
          namespace :app do
            resources :contacts
          end
        end
      end
    end
  end
end
