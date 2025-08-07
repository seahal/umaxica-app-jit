module Auth
  module App
    module Authentication
      class GooglesController < ApplicationController
        def new
          redirect_to "/auth/google_oauth2", allow_other_host: true
        end

        def create
          redirect_to "/auth/google_oauth2", allow_other_host: true
        end
      end
    end
  end
end
