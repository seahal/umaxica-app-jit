# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Com::InsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("IDENTITY_SIGN_COM_URL", "sign.com.localhost")
  end

  test "should get new" do
    get identity.new_sign_com_in_url(ri: "jp", host: @host)

    assert_response :success
  end

  test "rejects logged in customer on sign in page" do
    customer = create_verified_customer_with_email(email_address: "com-login-#{SecureRandom.hex(4)}@example.com")

    get identity.new_sign_com_in_url(ri: "jp", host: @host),
        headers: as_customer_headers(customer, host: @host)

    assert_redirected_to identity.new_sign_com_configuration_telephones_registration_path(ri: "jp")
  end
end
