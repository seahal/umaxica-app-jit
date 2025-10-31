Rails.application.routes.draw do
  scope module: :help, as: :help do
    constraints host: ENV["HELP_CORPORATE_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # contact page
        resources :contacts, only: [ :new, :create, :show ] do
          scope module: :contact do
            resource :email, only: [ :new, :create ]
            resource :telephone, only: [ :new, :create ]
          end
        end
      end
    end

    constraints host: ENV["HELP_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # contact page
        resources :inquiries, only: [ :new, :create, :edit, :update, :show ] do
          # TODO: Implement contact email and telephone functionality
          # scope module: :contact do
          #   resource :email, only: [ :new, :create ]
          #   resource :telephone, only: [ :new, :create ]
          # end
        end
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints host: ENV["HELP_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html/json
        resource :health, only: :show
        # api endpoint
        namespace :v1 do
          resource :health, only: :show
        end
        # TODO: Implement staff inquiry management
        # resources :inquiries, only: [ :new, :create, :edit, :update, :show ] do
        #   # TODO: Implement contact email and telephone functionality
        #   # scope module: :contact do
        #   #   resource :email, only: [ :new, :create ]
        #   #   resource :telephone, only: [ :new, :create ]
        #   # end
        # end
      end
    end
  end
end
