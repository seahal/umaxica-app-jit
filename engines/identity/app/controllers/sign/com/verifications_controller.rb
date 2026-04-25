# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Com
        class VerificationsController < Verification::BaseController
          include Jit::Identity::Sign::ComVerificationBase

          activate_com_verification_base
          include Jit::Identity::Sign::VerificationEntry

          private

          def verification_success_notice_key
            "sign.app.verification.success.complete"
          end

          def verification_invalid_request_redirect_path(ri:)
            identity.sign_com_configuration_path(ri: ri)
          end
        end
      end
    end
  end
end
