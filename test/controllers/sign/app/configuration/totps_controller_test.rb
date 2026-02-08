# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class Sign::App::Configuration::TotpsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users,
           :user_statuses,
           :user_token_statuses,
           :user_token_kinds,
           :user_one_time_password_statuses,
           :app_preference_audit_levels

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @token = UserToken.create!(user_id: @user.id)
    @headers = {
      "X-TEST-CURRENT-USER" => @user.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze
    @totp = UserOneTimePassword.create!(
      user: @user,
      private_key: ROTP::Base32.random_base32,
      last_otp_at: Time.zone.at(0),
      title: "Main TOTP",
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
    )
  end

  test "should get index" do
    get sign_app_configuration_totps_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should show up link on index page" do
    get sign_app_configuration_totps_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "a[href=?]", sign_app_configuration_path(ri: "jp")
  end

  test "should get new" do
    get new_sign_app_configuration_totp_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should get edit with public_id" do
    get edit_sign_app_configuration_totp_url(@totp.public_id, ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should update title with public_id" do
    patch sign_app_configuration_totp_url(@totp.public_id, ri: "jp"),
          params: { user_one_time_password: { title: "Updated TOTP" } },
          headers: @headers

    assert_redirected_to sign_app_configuration_totps_url(ri: "jp")
    assert_equal "Updated TOTP", @totp.reload.title
  end

  test "should destroy with public_id" do
    assert_difference("UserOneTimePassword.count", -1) do
      delete sign_app_configuration_totp_url(@totp.public_id, ri: "jp"), headers: @headers
    end

    assert_redirected_to sign_app_configuration_totps_url(ri: "jp")
  end

  test "should return 404 for other user's totp" do
    other_user = users(:two)
    other_totp = UserOneTimePassword.create!(
      user: other_user,
      private_key: ROTP::Base32.random_base32,
      last_otp_at: Time.zone.at(0),
      title: "Other TOTP",
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
    )

    get edit_sign_app_configuration_totp_url(other_totp.public_id, ri: "jp"), headers: @headers

    assert_response :not_found
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

  test "initial setup user can access totp pages without step-up" do
    user = User.create!
    token = UserToken.create!(user_id: user.id)
    token.update!(created_at: 1.hour.ago)
    headers = {
      "X-TEST-CURRENT-USER" => user.id,
      "X-TEST-SESSION-PUBLIC-ID" => token.public_id,
    }

    get sign_app_configuration_totps_url(ri: "jp"), headers: headers

    assert_response :success
  end

  test "initial setup user can create first totp without step-up" do
    user = User.create!
    token = UserToken.create!(user_id: user.id)
    token.update!(created_at: 1.hour.ago)
    headers = {
      "X-TEST-CURRENT-USER" => user.id,
      "X-TEST-SESSION-PUBLIC-ID" => token.public_id,
    }

    with_mocked_totp do |secret|
      get new_sign_app_configuration_totp_url(ri: "jp"), headers: headers
      first_code = ROTP::TOTP.new(secret).now

      assert_difference("UserOneTimePassword.count", 1) do
        post sign_app_configuration_totps_url(ri: "jp"),
             params: { user_one_time_password: { first_token: first_code } },
             headers: headers
      end
    end

    assert_redirected_to sign_app_configuration_totps_url(ri: "jp")
  end

  private

  def with_mocked_totp
    known_secret = "JBSWY3DPEHPK3PXP"
    ROTP::Base32.stub :random_base32, known_secret do
      yield known_secret
    end
  end
end
