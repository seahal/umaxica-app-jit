# typed: false
# frozen_string_literal: true

Jit::Zenith::Engine.routes.draw do
  # Zenith/Acme routes - Global BFF, dashboard, and settings

  scope module: :acme, as: :acme do
    constraints host: ENV["ZENITH_ACME_COM_URL"] do
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

    constraints host: ENV["ZENITH_ACME_APP_URL"] do
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

    constraints host: ENV["ZENITH_ACME_ORG_URL"] do
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
    constraints host: ENV["ZENITH_ACME_DEV_URL"] do
      scope module: :dev, as: :dev do
        root to: "roots#index"
        resource :health, only: :show
      end
    end

    # Private internal-service audience
    constraints host: ENV["ZENITH_ACME_NET_URL"] do
      scope module: :net, as: :net do
        root to: "roots#index"
        resource :health, only: :show
      end
    end
  end
end
