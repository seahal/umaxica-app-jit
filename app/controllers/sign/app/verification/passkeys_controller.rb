# typed: false
# frozen_string_literal: true

class Sign::App::Verification::PasskeysController < ApplicationController
  include Sign::AppVerificationBase
  include Sign::VerificationPasskeyActions
end
