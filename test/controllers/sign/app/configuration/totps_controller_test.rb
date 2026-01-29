# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class Sign::App::Configuration::TotpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @token = UserToken.create!(user_id: @user.id)
    @headers = {
      "X-TEST-CURRENT-USER" => @user.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze
  end

  test "should get index" do
    get sign_app_configuration_totps_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should get new" do
    get new_sign_app_configuration_totp_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should create totp with valid token" do
    with_mocked_totp do |secret|
      get new_sign_app_configuration_totp_url(ri: "jp"), headers: @headers
      token = ROTP::TOTP.new(secret).now

      assert_difference("UserOneTimePassword.count") do
        post sign_app_configuration_totps_url(ri: "jp"),
             params: { user_one_time_password: { first_token: token } },
             headers: @headers
      end

      assert_redirected_to %r{/configuration/totps}
    end
  end

  test "should assign attributes to created totp" do
    with_mocked_totp do |secret|
      get new_sign_app_configuration_totp_url(ri: "jp"), headers: @headers
      token = ROTP::TOTP.new(secret).now

      post sign_app_configuration_totps_url(ri: "jp"),
           params: { user_one_time_password: { first_token: token } },
           headers: @headers

      created_totp = UserOneTimePassword.order(created_at: :desc).first

      assert_equal @user, created_totp.user
      assert_not_nil created_totp.last_otp_at
    end
  end

  test "should not create totp with invalid token" do
    get new_sign_app_configuration_totp_url(ri: "jp"), headers: @headers

    assert_no_difference("UserOneTimePassword.count") do
      post sign_app_configuration_totps_url(ri: "jp"),
           params: { user_one_time_password: { first_token: "invalid" } },
           headers: @headers
    end

    assert_response :unprocessable_content
  end

  private

  def with_mocked_totp
    known_secret = "JBSWY3DPEHPK3PXP"
    ROTP::Base32.stub :random_base32, known_secret do
      yield known_secret
    end
  end
end
