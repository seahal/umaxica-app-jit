Rails.application.routes.draw do
  scope module: :help, as: :help do
    constraints host: ENV["HELP_CORPORATE_URL"] do
      scope module: :com, as: :com do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show
        # contact page
        resources :inquiries, only: [:new, :create, :edit, :update, :show] do
          scope module: :contact do
            resource :email, only: [:new, :create]
            resource :telephone, only: [:new, :create]
          end
        end
      end
    end

    constraints host: ENV["HELP_SERVICE_URL"] do
      scope module: :app, as: :app do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show
        # contact page
        resources :inquiries, only: [:new, :create, :edit, :update, :show] do
          scope module: :contact do
            resource :email, only: [:new, :create]
            resource :telephone, only: [:new, :create]
          end
        end
      end
    end

    # For Staff's webpages api.jp.example.org
    constraints host: ENV["HELP_STAFF_URL"] do
      scope module: :org, as: :org do
        root to: "roots#index"
        # health check for html
        resource :health, only: :show
        # contact page
        resources :inquiries, only: [:new, :create, :edit, :update, :show] do
          scope module: :contact do
            resource :email, only: [:new, :create]
            resource :telephone, only: [:new, :create]
          end
        end
      end
    end
  end
end
