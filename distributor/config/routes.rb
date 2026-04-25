# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Distributor/Post routes - Content delivery for docs, news, and help
  # These endpoints are accessed via closed network (Cloudflare VPN tunnel)

  # Flexible constraints for development
  com_url = ENV["DISTRIBUTOR_POST_COM_URL"]
  app_url = ENV["DISTRIBUTOR_POST_APP_URL"]
  org_url = ENV["DISTRIBUTOR_POST_ORG_URL"]
  dev_url = ENV["DISTRIBUTOR_POST_DEV_URL"]
  net_url = ENV["DISTRIBUTOR_POST_NET_URL"]

  com_constraints = ->(request) { com_url.blank? || request.host == com_url }
  app_constraints = ->(request) { app_url.blank? || request.host == app_url }
  org_constraints = ->(request) { org_url.blank? || request.host == org_url }
  dev_constraints = ->(request) { dev_url.blank? || request.host == dev_url }
  net_constraints = ->(request) { net_url.blank? || request.host == net_url }

  scope module: :post, as: :post do
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
          resource :callback, controller: "callbacks", only: :show
        end
        # api endpoint for web
        namespace :web do
          namespace :v0 do
            resource :cookie, only: %i(show update)
            resource :theme, only: %i(show update)
          end
        end
        # Edge API endpoint (browser/SPA)
        namespace :edge do
          namespace :v0, defaults: { format: :json } do
            resource :health, only: :show
            resource :sitemap, only: :show
            resources :documents, only: [:index, :show] do
              resources :versions, only: [:index, :show]
            end
            resources :timelines, only: [:index, :show] do
              resources :versions, only: [:index, :show]
            end
            resources :tags, only: :index
            resources :categories, only: :index
          end
        end
      end
    end

    constraints app_constraints do
      scope module: :app, as: :app do
        root to: "roots#index"
        # OIDC callback
        namespace :auth do
          resource :callback, controller: "callbacks", only: :show
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
          namespace :v0, defaults: { format: :json } do
            resource :health, only: :show
            resource :sitemap, only: :show
            resources :documents, only: [:index, :show] do
              resources :versions, only: [:index, :show]
            end
            resources :timelines, only: [:index, :show] do
              resources :versions, only: [:index, :show]
            end
            resources :tags, only: :index
            resources :categories, only: :index
          end
        end
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints org_constraints do
      scope module: :org, as: :org do
        root to: "roots#index"
        # OIDC callback
        namespace :auth do
          resource :callback, controller: "callbacks", only: :show
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
          namespace :v0, defaults: { format: :json } do
            resource :health, only: :show
            resource :sitemap, only: :show
            resources :documents, only: [:index, :show] do
              resources :versions, only: [:index, :show]
            end
            resources :timelines, only: [:index, :show] do
              resources :versions, only: [:index, :show]
            end
            resources :tags, only: :index
            resources :categories, only: :index
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
