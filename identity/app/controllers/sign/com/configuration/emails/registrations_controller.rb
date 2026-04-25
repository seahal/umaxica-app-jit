# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      module Emails
        class RegistrationsController < ApplicationController
          auth_required!

          include Sign::EmailRegistrationFlow

          activate_email_registration_flow
          include ::Verification::User

          before_action :authenticate_customer!

          private

          def email_registration_target_user
            current_customer
          end

          def after_email_registration_started_path(params = {})
            identity.edit_sign_com_configuration_emails_registration_path(params)
          end

          def new_email_registration_path(params = {})
            identity.new_sign_com_configuration_emails_registration_path(params)
          end

          def after_email_registration_verified_path
            identity.sign_com_configuration_emails_path(ri: params[:ri])
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
