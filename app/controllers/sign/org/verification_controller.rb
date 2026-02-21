# frozen_string_literal: true

class Sign::Org::VerificationController < Sign::Org::Verification::BaseController
  include Sign::VerificationEntry

  private

  def verification_success_notice_key
    "sign.org.verification.success.complete"
  end

  def verification_invalid_request_redirect_path(ri:)
    sign_org_configuration_path(ri: ri)
  end
end
