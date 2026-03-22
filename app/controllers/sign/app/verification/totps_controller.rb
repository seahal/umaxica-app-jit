# typed: false
# frozen_string_literal: true

class Sign::App::Verification::TotpsController < ApplicationController
  include Sign::AppVerificationBase
  include Sign::VerificationTotpActions
end
