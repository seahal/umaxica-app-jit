# frozen_string_literal: true

require "test_helper"

class Sign::App::VerificationControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
  end

  test "should get show" do
    get sign_app_verification_url(ri: "jp"), headers: @headers
    assert_response :success
  end

  test "shows setup message when no verification methods are registered" do
    user = User.create!
    headers = as_user_headers(user, host: @host)

    get sign_app_verification_url(ri: "jp"), headers: headers

    assert_response :success
    assert_includes response.body, "email/passkey/totp を登録してください"
  end
end
