# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Foundation/Base routes - Regional operations, contacts, and staff management
  # MissionControl::Jobs is mounted here

  # Flexible constraints for development
  com_url = ENV["FOUNDATION_BASE_COM_URL"]
  app_url = ENV["FOUNDATION_BASE_APP_URL"]
  org_url = ENV["FOUNDATION_BASE_ORG_URL"]
  dev_url = ENV["FOUNDATION_BASE_DEV_URL"]
  net_url = ENV["FOUNDATION_BASE_NET_URL"]

  com_constraints = ->(request) { com_url.blank? || request.host == com_url }
  app_constraints = ->(request) { app_url.blank? || request.host == app_url }
  org_constraints = ->(request) { org_url.blank? || request.host == org_url }
  dev_constraints = ->(request) { dev_url.blank? || request.host == dev_url }
  net_constraints = ->(request) { net_url.blank? || request.host == net_url }

  scope module: :base, as: :base do
    # for client site
    constraints com_constraints do
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
    constraints app_constraints do
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
    constraints org_constraints do
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
    constraints dev_constraints do
      mount MissionControl::Jobs::Engine, at: "/jobs"
      scope module: :dev, as: :dev do
        root to: "roots#index"
        resource :health, only: :show
      end
    end

    # Private internal-service audience
    constraints net_constraints do
      scope module: :net, as: :net do
        root to: "roots#index"
        resource :health, only: :show
      end
    end
  end
end
