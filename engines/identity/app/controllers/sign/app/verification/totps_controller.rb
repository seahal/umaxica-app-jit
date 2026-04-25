# typed: false
# frozen_string_literal: true

module Jit::Identity
    class Sign::App::Verification::TotpsController < Jit::Identity::Sign::App::Verification::BaseController
      include Jit::Identity::Sign::AppVerificationBase

      activate_app_verification_base
      include Jit::Identity::Sign::VerificationTotpActions
    end
  end
end
