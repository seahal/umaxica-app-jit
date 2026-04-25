# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Configuration
      module Emails
        class RegistrationsController < Sign::App::ApplicationController
          auth_required!

          include Sign::EmailRegistrationFlow

          activate_email_registration_flow
          include ::Verification::User

          before_action :authenticate_user!

          private

          def ensure_turnstile!(email_address, confirm_policy)
            turnstile_result = cloudflare_turnstile_stealth_validation
            return true if turnstile_result["success"]

            @user_email = UserEmail.new(raw_address: email_address, confirm_policy: confirm_policy)
            @user_email.errors.add(:base, t("sign.app.registration.email.create.turnstile_validation_failed"))
            false
          end

          def email_registration_target_user
            current_user
          end

          def after_email_registration_started_path(params = {})
            identity.edit_sign_app_configuration_emails_registration_path(params)
          end

          def new_email_registration_path(params = {})
            identity.new_sign_app_configuration_emails_registration_path(params)
          end

          def after_email_registration_verified_path
            identity.sign_app_configuration_emails_path
          end

          def verification_required_action?
            true
          end

          def verification_scope
            "configuration_email"
          end
        end
      end
    end
  end
end
