# typed: false
# frozen_string_literal: true

Jit::World::Engine.routes.draw do
  # World/Apex routes - Global BFF, dashboard, and settings

  scope module: :apex, as: :apex do
    constraints host: ENV["APEX_CORPORATE_URL"] do
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

    constraints host: ENV["APEX_SERVICE_URL"] do
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

    constraints host: ENV["APEX_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        resource :csp, only: :create
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
        # for emergency
        namespace :emergency do
          namespace :app do
            resource :token, only: %i(show update)
            resource :cache, only: %i(show update destroy)
          end
          namespace :com do
            resource :token, only: %i(show update)
            resource :cache, only: %i(show update destroy)
          end
          namespace :org do
            resource :cache, only: %i(show update destroy)
          end
        end
      end
    end
  end
end
