module Auth
  module App
    module V1
      class CsrfController < ApplicationController
        def show
          response.set_header("Cache-Control", "no-store")
          render json: {
            csrf_token: form_authenticity_token,
            csrf_param: request_forgery_protection_token
          }
        end
      end
    end
  end
end
