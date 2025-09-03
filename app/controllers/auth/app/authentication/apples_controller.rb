module Auth
  module App
    module Authentication
      class ApplesController < ApplicationController
        skip_forgery_protection only: :create

        def new
          redirect_to "/auth/apple", allow_other_host: true
        end

        def create
          redirect_to "/auth/apple", allow_other_host: true
        end
      end
    end
  end
end
