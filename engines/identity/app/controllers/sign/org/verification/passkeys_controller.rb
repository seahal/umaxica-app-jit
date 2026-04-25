# typed: false
# frozen_string_literal: true

module Jit::Identity
    class Sign::Org::Verification::PasskeysController < Jit::Identity::Sign::Org::Verification::BaseController
      include Jit::Identity::Sign::OrgVerificationBase

      activate_org_verification_base
      include Jit::Identity::Sign::VerificationPasskeyActions
    end
  end
end
