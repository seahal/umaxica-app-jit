module Sign
  module App
    module Authentication
      class GooglesController < ApplicationController
        def new
          redirect_to "/sign/google_oauth2", allow_other_host: true
        end

        def create
          redirect_to "/sign/google_oauth2", allow_other_host: true
        end
      end
    end
  end
end
