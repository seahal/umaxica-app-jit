# typed: false
# frozen_string_literal: true

require "test_helper"

class SignComVerificationBaseIncludedDoTest < ActiveSupport::TestCase
  test "included do includes Sign::AppVerificationBase module" do
    skip "Sign::ComVerificationBase requires authentication and preference dependencies"
  end
end
