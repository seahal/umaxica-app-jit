# typed: false
# frozen_string_literal: true

module Jit::Identity::Sign::App
  class VerificationsController < Verification::BaseController
    include Jit::Identity::Sign::AppVerificationBase

    activate_app_verification_base
    include Jit::Identity::Sign::VerificationEntry

    private

    def verification_success_notice_key
      "sign.app.verification.success.complete"
    end

    def verification_invalid_request_redirect_path(ri:)
      identity.sign_app_configuration_path(ri: ri)
    end
  end
end
