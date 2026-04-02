# typed: false
# frozen_string_literal: true

scope module: :core, as: :main do
  # for client site
  constraints host: (ENV["MAIN_CORPORATE_URL"] || ENV["CORE_CORPORATE_URL"]) do
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
  constraints host: (ENV["MAIN_SERVICE_URL"] || ENV["CORE_SERVICE_URL"]) do
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
  constraints host: (ENV["MAIN_STAFF_URL"] || ENV["CORE_STAFF_URL"]) do
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
      # for emergency
      namespace :emergency do
        namespace :app do
          resource :outage, only: %i(show update)
        end
        namespace :com do
          resource :outage, only: %i(show update)
        end
        namespace :org do
          resource :outage, only: %i(show update)
          resource :token, only: %i(show update)
        end
      end
      # for docs
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
      # for news
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
      # for help contacts
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
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
end
