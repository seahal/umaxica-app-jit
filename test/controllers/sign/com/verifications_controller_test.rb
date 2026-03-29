# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Com::VerificationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    host! @host
    @user = create_verified_user_with_email(email_address: "com-verification-#{SecureRandom.hex(4)}@example.com")
    @user.user_telephones.create!(
      number: "+8190#{SecureRandom.random_number(10**8).to_s.rjust(8, '0')}",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    @headers = as_user_headers(@user, host: @host)
  end

  test "should get show" do
    get sign_com_verification_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "redirects to setup page when no verification methods are registered" do
    user = User.create!
    user.user_telephones.create!(
      number: "+8190#{SecureRandom.random_number(10**8).to_s.rjust(8, '0')}",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    headers = as_user_headers(user, host: @host)

    get sign_com_verification_url(ri: "jp"), headers: headers

    assert_response :redirect
    uri = URI.parse(response.location)
    query = Rack::Utils.parse_query(uri.query)

    assert_equal "/verification/setup/new", uri.path
    assert_predicate query["rd"], :present?
  end

  test "show renders only email and passkey method links" do
    return_to = Base64.urlsafe_encode64(sign_com_configuration_emails_path(ri: "jp"))

    get sign_com_verification_url(scope: "configuration_email", return_to: return_to, ri: "jp"),
        headers: @headers

    assert_response :success
    assert_includes response.body, new_sign_com_verification_email_path(ri: "jp")
    assert_includes response.body, new_sign_com_verification_passkey_path(ri: "jp")
    assert_not_includes response.body, "/verification/totp"
  end

  test "show handles bad request error" do
    get sign_com_verification_url(scope: "configuration_email", return_to: "%%%INVALID%%%", ri: "jp"),
        headers: @headers

    assert_redirected_to sign_com_configuration_url(ri: "jp")
  end
end
