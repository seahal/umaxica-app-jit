# frozen_string_literal: true

module Sign
  module App
    module Configuration
      module Emails
        class RegistrationsController < ::Sign::App::Configuration::ApplicationController
          include Sign::EmailRegistrationFlow
          include ::Auth::StepUp

          before_action :authenticate_user!
          before_action -> { require_step_up!(scope: "configuration_email") }

          private

          def email_registration_target_user
            current_user
          end

          def after_email_registration_started_path(params = {})
            edit_sign_app_configuration_emails_registration_path(params)
          end

          def new_email_registration_path(params = {})
            new_sign_app_configuration_emails_registration_path(params)
          end

          def after_email_registration_verified_path
            sign_app_configuration_emails_path
          end
        end
      end
    end
  end
end
