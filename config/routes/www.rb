Rails.application.routes.draw do
  scope module: :www, as: :www do
    constraints host: ENV["WWW_CORPORATE_URL"] do
      scope module: :com, as: :com do
        #
        root to: redirect("https://#{ENV['EDGE_CORPORATE_URL']}")
        # health check for html
        resource :health, only: :show
        # show latest 'term of use'
        resource :term, only: :show
        # show stating env
        resource :staging, only: :show
        # show search pages
        resource :search, only: :show
        # non-loggined settings
        resource :privacy, only: [ :show, :edit ]
        # contact page
        resource :contact, only: :new, shallow: true do
          resources :email, only: [ :update, :show ]
          resources :telephone, only: [ :update, :show ]
          resources :message, only: [ :update, :create ]
        end
        # robots.txt
        resources :robots, only: :index, format: :txt
        # sitemap.xml
        resource :sitemap, only: :show, format: :xml
        # Security
        get "/security(.:format)", to: redirect("#{ENV['EDGE_CORPORATE_URL']}/security.html"), as: :security
      end

      constraints host: ENV["WWW_SERVICE_URL"] do
        scope module: :net, as: :net do
          # homepage
          root to: redirect("https://#{ENV['EDGE_SERVICE_URL']}")
          # root to: "roots#index"
          resource :health, only: :show # health check for html
          # show latest 'term of use'
          resource :term, only: :show
          # show stating env
          resource :staging, only: :show
          # non-loggined settings
          resource :privacy, only: [ :show, :edit ]
          # contact page
          resource :contact, only: :new, shallow: true do
            resources :email, only: [ :update, :show ]
            resources :telephone, only: [ :update, :show ]
            resources :message, only: [ :update, :create ]
          end
          # Sign up pages
          resource :registration, only: :new, shallow: true do
            resource :email, only: %i[new create edit update]
            resource :telephone, only: %i[new create edit update]
            resource :google, only: %i[new create]
            resource :apple, only: %i[new create]
          end
          # Withdrawal
          resource :withdrawal, only: %i[edit destroy] # TODO: Create or Delete membership
          # Sign In/Out, NEED WEB
          resource :session, only: %i[new destroy]
          # todo: rewrite namespace
          namespace :session do
            resource :email, only: %i[new create]
            resource :google, only: %i[new create]
            resource :apple, only: %i[new create]
            resource :passkey, only: %i[new create]
            resource :password, only: %i[new create]
          end
          # Settings
          resource :preference, only: :show
          # robots.txt
          resources :robots, only: :index, format: :txt
          # sitemap.xml
          resource :sitemap, only: :show, format: :xml
          # Security
          get "/security(.:format)", to: redirect("#{ENV['EDGE_SERVICE_URL']}/security.html"), as: :security
        end
      end
    end

    # For Staff's webpages www.jp.example.org
    constraints host: ENV["WWW_STAFF_URL"] do
      scope module: :org, as: :org do
        # Homepage
        root to: redirect("https://#{ENV['EDGE_STAFF_URL']}")
        # health check for html
        resource :health, only: :show
        # show 'term of use'
        resource :term, only: :show
        # show stating env
        resource :staging, only: :show
        # non-loggined settings
        resource :privacy, only: [ :show, :edit ]
        # contact page
        namespace :contact do
          resources :email, only: [ :update, :show ]
          resources :telephone, only: [ :update, :show ]
          resources :message, only: [ :update, :create ]
        end
        # TODO: Owner's lounge
        resource :owner, only: :show
        # Sign up pages
        # todo: rewrite namespace
        resource :registration, only: :new, shallow: true do
          resources :emails, only: %i[create edit update]
        end
        # TODO: Create or Delete membership
        namespace :membership do
        end
        # TODO: Login or Logout
        resource :session, only: :new, shallow: true do
          resource :email, only: %i[new create]
        end
        # robots.txt
        resources :robots, only: :index, format: :txt
        # sitemap
        resource :sitemap, only: :show, format: :xml
        # Security
        get "/security(.:format)", to: redirect("#{ENV['EDGE_STAFF_URL']}/security.html"), as: :security
      end
    end
  end
end
