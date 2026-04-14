# typed: false
# frozen_string_literal: true

class Sign::Org::Verification::PasskeysController < Sign::Org::Verification::BaseController
  include Sign::OrgVerificationBase

  activate_org_verification_base
  include Sign::VerificationPasskeyActions
end
