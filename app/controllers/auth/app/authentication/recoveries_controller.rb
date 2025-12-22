module Auth
  module App
    module Authentication
      class RecoveriesController < ApplicationController
        def new
          @user_recover_code = RecoveryForm.new
        end

        def create
          @user_recover_code = RecoveryForm.new(recovery_params)
          render :new, status: :unprocessable_content
        end

        private

          def recovery_params
            params.fetch(:recovery_form, {}).permit(:account_identifiable_information, :recovery_code)
          end

          class RecoveryForm
            include ActiveModel::Model

            attr_accessor :account_identifiable_information, :recovery_code
          end
      end
    end
  end
end
