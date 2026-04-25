# typed: false
# frozen_string_literal: true

module Jit::Identity
    class Sign::App::Verification::TotpsController < Sign::App::Verification::BaseController
      include Sign::AppVerificationBase

      activate_app_verification_base
      include Sign::VerificationTotpActions
    end
  end
end
