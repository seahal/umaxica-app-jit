# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class TelephonesController < ApplicationController
        include Sign::App::TelephoneRegistrationFlow

        before_action :authenticate_user!
        before_action :enforce_flow!, only: %i[edit update show]

        # ==========================================================================
        # Index: List registered telephones
        # ==========================================================================

        def index
          reset_flow!
          @user_telephones = current_user.user_telephones.where.not(
            user_telephone_status_id: TELEPHONE_STATUSES[:unverified]
          )
        end

        # ==========================================================================
        # Step 3: Confirmation
        # ==========================================================================

        def show
          @user_telephone = current_user.user_telephones.find_by(id: params[:id])

          unless @user_telephone
            reset_flow!
            redirect_to sign_app_configuration_telephones_path,
                        alert: t("sign.app.configuration.telephone.show.not_found")
          end
        end
        # ==========================================================================
        # Step 1: Telephone Input
        # ==========================================================================

        def new
          @user_telephone = UserTelephone.new
        end

        # ==========================================================================
        # Step 2: OTP Verification
        # ==========================================================================

        def edit
          redirect_to_flow_start unless load_telephone_for_verification(params[:id])
        end

        def create
          telephone_params = params.expect(user_telephone: [ :telephone_number ])

          if initiate_telephone_registration(
            telephone_params[:telephone_number],
            confirm_policy: "1", # Skip policy for logged-in users
            confirm_using_mfa: "1", # Skip MFA confirmation for logged-in users
            validate_turnstile: false # Skip Turnstile for logged-in users
          )
            advance_step!
            redirect_to edit_sign_app_configuration_telephone_path(@user_telephone),
                        notice: t("sign.app.configuration.telephone.create.verification_code_sent")
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          submitted_code = params[:user_telephone][:pass_code]

          result = complete_telephone_registration(params[:id], submitted_code) do |user_telephone|
            user_telephone.user = current_user
            user_telephone.save!
          end

          handle_verification_result(result)
        end

        # ==========================================================================
        # Destroy: Deactivate/Delete telephone
        # ==========================================================================

        def destroy
          @user_telephone = current_user.user_telephones.find_by(id: params[:id])

          if @user_telephone.nil?
            redirect_to sign_app_configuration_telephones_path,
                        alert: t("sign.app.configuration.telephone.destroy.not_found")
            return
          end

          # Prevent deleting the last verified telephone (optional - uncomment if required)
          # verified_count = current_user.user_telephones.where(
          #   user_telephone_status_id: TELEPHONE_STATUSES[:verified]
          # ).count
          #
          # if verified_count <= 1 && @user_telephone.user_telephone_status_id == TELEPHONE_STATUSES[:verified]
          #   redirect_to sign_app_configuration_telephones_path,
          #               alert: t("sign.app.configuration.telephone.destroy.last_telephone")
          #   return
          # end

          @user_telephone.update!(user_telephone_status_id: UserTelephoneStatus::DELETED)

          redirect_to sign_app_configuration_telephones_path,
                      notice: t("sign.app.configuration.telephone.destroy.success")
        end

        private

          def flow_initial_path
            new_sign_app_configuration_telephone_path
          end

          def redirect_to_flow_start
            redirect_to new_sign_app_configuration_telephone_path,
                        alert: t("sign.app.configuration.telephone.edit.session_expired")
          end

          def handle_verification_result(result)
            case result
            when :success
              advance_step!
              redirect_to sign_app_configuration_telephone_path(@user_telephone),
                          notice: t("sign.app.configuration.telephone.update.success")
            when :session_expired
              reset_flow!
              redirect_to new_sign_app_configuration_telephone_path,
                          alert: t("sign.app.configuration.telephone.update.session_expired")
            when :locked
              reset_flow!
              redirect_to new_sign_app_configuration_telephone_path,
                          alert: t("sign.app.configuration.telephone.update.attempts_exceeded")
            when :invalid_code
              render :edit, status: :unprocessable_content
            end
          end
      end
    end
  end
end
