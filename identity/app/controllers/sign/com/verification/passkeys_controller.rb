# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Verification
      class PasskeysController < Sign::Com::ApplicationController
        include Sign::ComVerificationBase

        activate_com_verification_base
        include Sign::VerificationPasskeyActions
      end
    end
  end
end
