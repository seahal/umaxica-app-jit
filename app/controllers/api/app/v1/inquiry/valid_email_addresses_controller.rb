module Api
  module App
    module V1
      module Inquiry
        class ValidEmailAddressesController < ApplicationController
          def show
            email_address = Base64.urlsafe_decode64(params[:id])
            validness = AppContactEmail.new(email_address: email_address)
            validness.valid?
            if validness.errors[:email_address].length == 0
              render json: { valid: true }
            else
              render json: { valid: false }
            end
          end
        end
      end
    end
  end
end
