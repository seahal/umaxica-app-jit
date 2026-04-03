# typed: false
# frozen_string_literal: true

class Sign::App::Verification::PasskeysController < Sign::App::Verification::BaseController
  include Sign::AppVerificationBase

  activate_app_verification_base
  include Sign::VerificationPasskeyActions
end
