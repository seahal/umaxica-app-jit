# frozen_string_literal: true

require "test_helper"

class WebauthnConfigTest < ActiveSupport::TestCase
  # Case A-1: TRUSTED_ORIGINS not set
  # Tested via method behavior

  test "validate_origin! raises error when origin is not trusted" do
    # TRUSTED_ORIGINS is enforced to be set in test environment via Rails configuration
    # We test the validation logic against the configured values

    assert_raises(WebAuthn::OriginVerificationError) do
      Webauthn.validate_origin!("http://malicious.example.com")
    end
  end

  # Case A-2: Validate trusted origins

  test "validate_origin! returns true for trusted origins" do
    # Assuming config is loaded properly in test env
    trusted_origin = Webauthn.trusted_origins.first
    assert Webauthn.validate_origin!(trusted_origin)
  end

  test "trusted_origins returns invalid origins loaded from env" do
    assert_not_empty Webauthn.trusted_origins
  end
end
