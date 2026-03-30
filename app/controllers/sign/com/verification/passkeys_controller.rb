# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Verification
      class PasskeysController < Sign::Com::ApplicationController
        include Sign::ComVerificationBase
        include Sign::VerificationPasskeyActions
      end
    end
  end
end
