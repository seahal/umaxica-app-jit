# typed: false
# frozen_string_literal: true

require_relative "../test_helper"

class NamespaceLeakTest < ActiveSupport::TestCase
  # This test is intentionally failing (Red) in Stage A to document namespace leakage.
  # AC-5: Real code must be under Jit::* namespace.

  CONCERNS = %w(
    Session
    Preference
    Authentication
    Authorization
    Verification
    Oidc
    CsrfTrustedOrigins
    EmailValidation
    IdentifierDetection
    RestrictedSessionGuard
    SessionLimitGate
    SocialAuthConcern
    SocialCallbackGuard
  ).freeze

  test "concerns are not leaked to top-level namespace" do
    CONCERNS.each do |concern|
      assert_nil defined?("::#{concern}"), "::#{concern} should NOT be defined at top-level"
    end
  end

  test "concerns are defined under Jit::Identity" do
    CONCERNS.each do |concern|
      assert Jit::Identity.const_defined?(concern), "Jit::Identity::#{concern} should be defined"
    end
  end

  test "ActivityRecord is defined under Jit::Identity" do
    assert Jit::Identity.const_defined?(:ActivityRecord), "Jit::Identity::ActivityRecord should be defined"
    assert_nil defined?(::ActivityRecord), "::ActivityRecord should NOT be defined at top-level"
  end
end
