module Api
  module App
    module V1
      module Inquiry
        class ValidTelephoneNumbersController < ApplicationController
          def create
            telephone_number = params[:telephone_number]
            validness = AppContact.new(telephone_number: telephone_number)
            validness.valid?
            if validness.errors[:telephone_number].length == 0
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
