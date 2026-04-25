# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Com
        module Verification
          class PasskeysController < Jit::Identity::Sign::Com::ApplicationController
            include Jit::Identity::Sign::ComVerificationBase

            activate_com_verification_base
            include Jit::Identity::Sign::VerificationPasskeyActions
          end
        end
      end
    end
  end
end
