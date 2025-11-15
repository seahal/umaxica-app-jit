module Api
  module App
    module V1
      module Inquiry
        class ValidTelephoneNumbersController < ApplicationController
          def create
            telephone_number = params[:telephone_number]
            validness = AppContactTelephone.new(telephone_number: telephone_number)
            validness.valid?
            if validness.errors[:telephone_number].length == 0
              render json: { valid: true }, status: :ok
            else
              render json: {
                valid: false,
                errors: validness.errors.full_messages_for(:telephone_number)
              }, status: :unprocessable_entity
            end
          end
        end
      end
    end
  end
end
