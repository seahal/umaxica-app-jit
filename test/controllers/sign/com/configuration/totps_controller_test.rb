# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Com::Configuration::TotpsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_token_statuses, :user_token_kinds, :user_one_time_password_statuses,
           :app_preference_activity_levels, :user_telephone_statuses

  setup do
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    host! @host
    @user = users(:one)
    @user.user_telephones.destroy_all
    @user.user_telephones.create!(
      number: "+819055555555",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    @user.user_one_time_passwords.destroy_all

    @token = UserToken.create!(user_id: @user.id)
    satisfy_user_verification(@token)
    @headers = as_user_headers(@user, host: @host).merge("X-TEST-SESSION-PUBLIC-ID" => @token.public_id)

    @totp = UserOneTimePassword.create!(
      user: @user,
      private_key: ROTP::Base32.random_base32,
      last_otp_at: Time.zone.at(0),
      title: "Main TOTP",
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
    )
  end

  test "redirects unauthenticated user to login" do
    get sign_com_configuration_totps_path(ri: "jp")

    assert_response :redirect
  end

  test "should get index" do
    get sign_com_configuration_totps_path(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should get new" do
    get new_sign_com_configuration_totp_path(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should create totp with valid token" do
    @user.user_one_time_passwords.destroy_all

    with_mocked_totp do |secret|
      get new_sign_com_configuration_totp_path(ri: "jp"), headers: @headers
      token = ROTP::TOTP.new(secret).now

      assert_difference("UserOneTimePassword.count", 1) do
        post sign_com_configuration_totps_path(ri: "jp"),
             params: { user_one_time_password: { first_token: token } },
             headers: @headers
      end
    end

    assert_redirected_to sign_com_configuration_totps_path(ri: "jp")
  end

  test "should not create totp with invalid token" do
    get new_sign_com_configuration_totp_path(ri: "jp"), headers: @headers

    assert_no_difference("UserOneTimePassword.count") do
      post sign_com_configuration_totps_path(ri: "jp"),
           params: { user_one_time_password: { first_token: "000000" } },
           headers: @headers
    end

    assert_response :unprocessable_content
  end

  private

  def with_mocked_totp
    known_secret = "JBSWY3DPEHPK3PXP"
    ROTP::Base32.stub(:random_base32, known_secret) do
      yield known_secret
    end
  end
end
