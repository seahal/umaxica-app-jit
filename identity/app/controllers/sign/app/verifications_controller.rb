# typed: false
# frozen_string_literal: true

module Sign::App
  class VerificationsController < Verification::BaseController
    include Sign::AppVerificationBase

    activate_app_verification_base
    include Sign::VerificationEntry

    private

    def verification_success_notice_key
      "sign.app.verification.success.complete"
    end

    def verification_invalid_request_redirect_path(ri:)
      identity.sign_app_configuration_path(ri: ri)
    end
  end
end
