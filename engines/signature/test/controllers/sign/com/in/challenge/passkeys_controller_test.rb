# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Com::In::Challenge::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    host! @host
    @origin_headers = { "HTTP_ORIGIN" => "http://#{@host}", "Origin" => "http://#{@host}" }.freeze
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }

    @original_trusted_origins = Webauthn.method(:trusted_origins)
    Webauthn.define_singleton_method(:trusted_origins) do
      ["http://#{@host}", "https://#{@host}", "http://sign.app.localhost", "https://sign.app.localhost"]
    end

    @customer = create_verified_customer_with_email(email_address: "com_mfa_passkey_#{SecureRandom.hex(4)}@example.com")
    @customer.update!(multi_factor_enabled: true)
    @customer.customer_telephones.create!(
      number: "+8190" + format("%08d", SecureRandom.random_number(100_000_000)),
      customer_telephone_status_id: CustomerTelephoneStatus::VERIFIED,
    )

    @passkey = CustomerPasskey.create!(
      customer: @customer,
      webauthn_id: Base64.urlsafe_encode64("com_mfa_passkey_id_eeec6cca6c4c1cbd", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "mfa-passkey-public",
      sign_count: 5,
      description: "MFA Passkey",
      status_id: CustomerPasskeyStatus::ACTIVE,
    )

    @secret = @customer.customer_secrets.create!(name: "Passkey MFA secret", password: "a" * 32)
    @raw_secret = "a" * 32
  end

  teardown do
    Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins) if @original_trusted_origins
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "new requires pending MFA session" do
    get new_sign_com_in_challenge_passkey_path(ri: "jp"), headers: @origin_headers

    assert_redirected_to new_sign_com_in_path(ri: "jp")
  end

  private

  def establish_pending_mfa!
    post(
      sign_com_in_secret_path(ri: "jp"), params: {
        secret_login_form: {
          identifier: @customer.customer_emails.first.address,
          secret_value: @raw_secret,
        },
        "cf-turnstile-response": "test_token",
      }, headers: @origin_headers,
    )

    assert_response :redirect
  end
end
