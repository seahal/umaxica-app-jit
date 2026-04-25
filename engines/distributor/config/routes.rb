# typed: false
# frozen_string_literal: true

Jit::Distributor::Engine.routes.draw do
  # Distributor/Post routes - Content delivery for docs, news, and help
  # These endpoints are accessed via closed network (Cloudflare VPN tunnel)

  scope module: :post, as: :post do
    constraints host: ENV["DISTRIBUTOR_POST_COM_URL"] do
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

    constraints host: ENV["DISTRIBUTOR_POST_APP_URL"] do
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
    constraints host: ENV["DISTRIBUTOR_POST_ORG_URL"] do
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
    constraints host: ENV["DISTRIBUTOR_POST_DEV_URL"] do
      scope module: :dev, as: :dev do
        root to: "roots#index"
        resource :health, only: :show
      end
    end

    # Private internal-service audience
    constraints host: ENV["DISTRIBUTOR_POST_NET_URL"] do
      scope module: :net, as: :net do
        root to: "roots#index"
        resource :health, only: :show
      end
    end
  end
end
