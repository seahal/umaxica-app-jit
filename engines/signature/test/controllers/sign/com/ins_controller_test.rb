# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Com::InsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
  end

  test "should get new" do
    get new_sign_com_in_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :success
  end

  test "rejects logged in customer on sign in page" do
    customer = create_verified_customer_with_email(email_address: "com-login-#{SecureRandom.hex(4)}@example.com")

    get new_sign_com_in_url(ri: "jp"),
        headers: as_customer_headers(customer, host: @host)

    assert_redirected_to new_sign_com_configuration_telephones_registration_path(ri: "jp")
  end
end
