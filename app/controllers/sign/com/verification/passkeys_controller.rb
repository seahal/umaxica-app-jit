# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Verification
      # FIXME: BaseController is bad practive, and you should remove this.
      class PasskeysController < BaseController
        include Sign::VerificationPasskeyActions
      end
    end
  end
end
