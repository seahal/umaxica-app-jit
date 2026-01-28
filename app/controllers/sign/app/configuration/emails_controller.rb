# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class EmailsController < ApplicationController
        include Sign::App::EmailRegistrationFlow

        before_action :enforce_flow!, only: %i[edit update show]

        # ==========================================================================
        # Index: List registered emails
        # ==========================================================================

        def index
          reset_flow!
          @user_emails = current_user.user_emails.where.not(
            user_email_status_id: EMAIL_STATUSES[:unverified]
          )
        end

        # ==========================================================================
        # Step 3: Confirmation
        # ==========================================================================

        def show
          @user_email = current_user.user_emails.find_by(public_id: params[:id])

          unless @user_email
            reset_flow!
            redirect_to sign_app_configuration_emails_path,
                        alert: t("sign.app.configuration.email.show.not_found")
          end
        end
        # ==========================================================================
        # Step 1: Email Input
        # ==========================================================================

        def new
          @user_email = UserEmail.new
        end

        # ==========================================================================
        # Step 2: OTP Verification
        # ==========================================================================

        def edit
          redirect_to_flow_start unless load_email_for_verification(params[:id])
        end

        def create
          email_params = params.expect(user_email: [ :address ])

          if initiate_email_registration(
            email_params[:address],
            confirm_policy: "1", # Skip policy for logged-in users
            validate_turnstile: true
          )
            advance_step!
            redirect_to edit_sign_app_configuration_email_path(@user_email),
                        notice: t("sign.app.configuration.email.create.verification_code_sent")
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          submitted_code = params[:user_email][:pass_code]
          token = params[:user_email][:token]

          result = complete_email_registration(params[:id], submitted_code, token) do |user_email|
            user_email.user = current_user
            user_email.save!

            # Upgrade user status if needed
            if current_user.status_id == UserStatus::UNVERIFIED_WITH_SIGN_UP
              current_user.status_id = UserStatus::VERIFIED_WITH_SIGN_UP
              current_user.save!
            end
          end

          handle_verification_result(result)
        end

        # ==========================================================================
        # Destroy: Deactivate/Delete email
        # ==========================================================================

        def destroy
          @user_email = current_user.user_emails.find_by(public_id: params[:id])

          if @user_email.nil?
            redirect_to sign_app_configuration_emails_path,
                        alert: t("sign.app.configuration.email.destroy.not_found")
            return
          end

          # Prevent deleting the last verified email
          verified_count = current_user.user_emails.where(
            user_email_status_id: EMAIL_STATUSES[:verified]
          ).count

          if verified_count <= 1 && @user_email.user_email_status_id == EMAIL_STATUSES[:verified]
            redirect_to sign_app_configuration_emails_path,
                        alert: t("sign.app.configuration.email.destroy.last_email")
            return
          end

          @user_email.update!(user_email_status_id: UserEmailStatus::DELETED)

          redirect_to sign_app_configuration_emails_path,
                      notice: t("sign.app.configuration.email.destroy.success")
        end

        private

          def flow_initial_path
            new_sign_app_configuration_email_path
          end

          def redirect_to_flow_start
            redirect_to new_sign_app_configuration_email_path,
                        alert: t("sign.app.configuration.email.edit.session_expired")
          end

          def handle_verification_result(result)
            case result
            when :success
              advance_step!
              redirect_to sign_app_configuration_email_path(@user_email),
                          notice: t("sign.app.configuration.email.update.success")
            when :session_expired
              reset_flow!
              redirect_to new_sign_app_configuration_email_path,
                          alert: t("sign.app.configuration.email.update.session_expired")
            when :locked
              reset_flow!
              redirect_to new_sign_app_configuration_email_path,
                          alert: t("sign.app.configuration.email.update.attempts_exceeded")
            when :invalid_code, :invalid_token
              render :edit, status: :unprocessable_content
            end
          end
      end
    end
  end
end
