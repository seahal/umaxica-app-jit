# typed: false
# frozen_string_literal: true

Jit::Foundation::Engine.routes.draw do
  # Foundation/Base routes - Regional operations, contacts, and staff management
  # MissionControl::Jobs is mounted here

  scope module: :base, as: :base do
    # for client site
    constraints host: ENV["FOUNDATION_BASE_COM_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # Health
        resource :health, only: :show
        # Robots
        resource :robots, only: :show, path: "robots.txt"
        # Sitemap
        resource :sitemap, only: :show, path: "sitemap.xml"
        # OIDC callback
        namespace :auth do
          resource :callback, only: :show
        end
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
            resource :preference, only: %i(show create)
            resources :messages, only: %i(index show create update destroy)
          end
        end
        # configuration
        resource :configuration, only: [:show]
        # contact page
        resources :contacts, only: %i(new create show)
      end
    end

    # service page
    constraints host: ENV["FOUNDATION_BASE_APP_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # OIDC callback
        namespace :auth do
          resource :callback, only: :show
        end
        # Health
        resource :health, only: :show
        # Robots
        resource :robots, only: :show, path: "robots.txt"
        # Sitemap
        resource :sitemap, only: :show, path: "sitemap.xml"
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
            resource :preference, only: :show
            resources :messages, only: %i(index show create update destroy)
          end
        end
        # configuration
        resource :configuration, only: [:show] do
          scope module: :configuration do
            resources :emails, only: [:new, :create]
          end
        end
        # contact page
        resources :contacts, only: %i(new create show)
      end
    end

    # For Staff's webpages
    constraints host: ENV["FOUNDATION_BASE_ORG_URL"] do
      # mount Karafka::Web::App, at: "/karafka"
      scope module: :org, as: :org do
        root to: "roots#index"
        # OIDC callback
        namespace :auth do
          resource :callback, only: :show
        end
        # Health
        resource :health, only: :show
        # Robots
        resource :robots, only: :show, path: "robots.txt"
        # Sitemap
        resource :sitemap, only: :show, path: "sitemap.xml"
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
            resource :preference, only: :show
            resources :messages, only: %i(index show create update destroy)
          end
        end
        # configuration
        resource :configuration, only: [:show] do
          scope module: :configuration do
            resources :emails, only: [:new, :create]
          end
        end
        # contact page
        resources :contacts, only: %i(new create show)
      end
    end

    # Developer and operational tooling
    constraints host: ENV["FOUNDATION_BASE_DEV_URL"] do
      mount MissionControl::Jobs::Engine, at: "/jobs"
      scope module: :dev, as: :dev do
        root to: "roots#index"
        resource :health, only: :show
      end
    end

    # Private internal-service audience
    constraints host: ENV["FOUNDATION_BASE_NET_URL"] do
      scope module: :net, as: :net do
        root to: "roots#index"
        resource :health, only: :show
      end
    end
  end
end
