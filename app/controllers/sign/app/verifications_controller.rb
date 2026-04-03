# typed: false
# frozen_string_literal: true

class Sign::App::VerificationsController < Sign::App::Verification::BaseController
  include Sign::AppVerificationBase

  activate_app_verification_base
  include Sign::VerificationEntry

  private

  def verification_success_notice_key
    "sign.app.verification.success.complete"
  end

  def verification_invalid_request_redirect_path(ri:)
    sign_app_configuration_path(ri: ri)
  end
end
