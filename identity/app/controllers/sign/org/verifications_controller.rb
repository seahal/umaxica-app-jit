# typed: false
# frozen_string_literal: true

module Jit::Identity
    class Sign::Org::VerificationsController < Sign::Org::Verification::BaseController
      include Sign::OrgVerificationBase

      activate_org_verification_base
      include Sign::VerificationEntry

      private

      def verification_success_notice_key
        "sign.org.verification.success.complete"
      end

      def verification_invalid_request_redirect_path(ri:)
        identity.sign_org_configuration_path(ri: ri)
      end
    end
  end
end
