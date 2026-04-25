# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Zenith/Acme routes - Global BFF, dashboard, and settings

  # Flexible constraints for development
  app_url = ENV["ZENITH_ACME_APP_URL"]
  com_url = ENV["ZENITH_ACME_COM_URL"]
  org_url = ENV["ZENITH_ACME_ORG_URL"]
  dev_url = ENV["ZENITH_ACME_DEV_URL"]
  net_url = ENV["ZENITH_ACME_NET_URL"]

  app_constraints = ->(request) { app_url.blank? || request.host == app_url }
  com_constraints = ->(request) { com_url.blank? || request.host == com_url }
  org_constraints = ->(request) { org_url.blank? || request.host == org_url }
  dev_constraints = ->(request) { dev_url.blank? || request.host == dev_url }
  net_constraints = ->(request) { net_url.blank? || request.host == net_url }

  scope module: :acme, as: :acme do
    constraints com_constraints do
      scope module: :com, as: :com do
        root to: "roots#index"
        resource :csp, only: :create
        # Health
        resource :health, only: :show
        # Robots
        resource :robots, only: :show, path: "robots.txt"
        # Sitemap
        resource :sitemap, only: :show, path: "sitemap.xml"
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

    constraints app_constraints do
      scope module: :app, as: :app do
        root to: "roots#index"
        resource :csp, only: :create
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
        # for emergency token operations
        namespace :emergency do
          namespace :app do
            resource :token, only: %i(show update)
          end
        end
      end
    end

    constraints org_constraints do
      scope module: :org, as: :org do
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
      end
    end

    # Developer and operational tooling
    constraints dev_constraints do
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
