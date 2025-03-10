Rails.application.routes.draw do
  constraints host: ENV["DEVELOPER_URL"] do
    # Homepage
    scope module: :dev, as: :dev do
      # Homepage
      root to: "roots#index"

      # for api
      resource :api, only: :show do
        scope module: :api do
          resource :com, only: [ :show ]
          resource :net, only: [ :show ]
          resource :org, only: [ :show ]
        end
      end

      # for www
      resource :www, only: :show do
        scope module: :www do
          resource :com, only: [ :show ]
          resource :net, only: [ :show ]
          resource :org, only: [ :show ]
        end
      end
    end
  end
end
