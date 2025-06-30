module Api
  module App
    module V1
      module Inquiry
        class TelephoneNumbersController < ApplicationController
          def show
            var = Base64.urlsafe_decode64(params[:id])
            render json: { valid: true }
          end
        end
      end
    end
  end
end
