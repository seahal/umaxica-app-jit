# typed: false
# frozen_string_literal: true

class Sign::Org::Verification::TotpsController < Sign::Org::Verification::BaseController
  include Sign::VerificationTotpActions
end
