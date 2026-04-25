# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Com::Configuration::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("IDENTITY_SIGN_COM_URL", "sign.com.localhost")
    host! @host
    @origin_headers = { "HTTP_ORIGIN" => "http://#{@host}", "Origin" => "http://#{@host}" }.freeze
    @customer = create_verified_customer_with_email(email_address: "com_passkey_config@example.com")
    @customer.customer_telephones.create!(
      number: "+819044444444",
      customer_telephone_status_id: CustomerTelephoneStatus::VERIFIED,
    )
    @headers = as_customer_headers(@customer, host: @host)
    @token = CustomerToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
    satisfy_customer_verification(@token)

    @original_trusted_origins = Webauthn.method(:trusted_origins)
    Webauthn.define_singleton_method(:trusted_origins) do
      [
        "http://sign.app.localhost",
        "https://sign.app.localhost",
        "http://sign.app.localhost:3000",
        "https://sign.app.localhost:3000",
        "http://#{@host}",
        "https://#{@host}",
        "http://#{@host}:3000",
        "https://#{@host}:3000",
      ]
    end

    @passkey = CustomerPasskey.create!(
      customer: @customer,
      webauthn_id: Base64.urlsafe_encode64("com_existing_credential", padding: false),
      public_key: "public_key_#{SecureRandom.hex(4)}",
      sign_count: 0,
      description: "My Passkey",
      status_id: CustomerPasskeyStatus::ACTIVE,
    )
  end

  teardown do
    Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins)
  end

  test "redirects unauthenticated user to login" do
    get sign_com_configuration_passkeys_path(ri: "jp")

    assert_response :redirect
  end

  test "should get index" do
    get sign_com_configuration_passkeys_path(ri: "jp"), headers: @headers

    assert_response :success
  end
end
