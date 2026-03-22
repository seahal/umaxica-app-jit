# typed: false
# frozen_string_literal: true

class Sign::Org::Verification::PasskeysController < ApplicationController
  include Sign::OrgVerificationBase
  include Sign::VerificationPasskeyActions
end
