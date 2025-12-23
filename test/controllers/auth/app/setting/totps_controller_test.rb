require "test_helper"
require "minitest/mock"

class Auth::App::Setting::TotpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get index" do
    get auth_app_setting_totps_url, headers: @headers

    assert_response :success
  end

  test "should get new" do
    get new_auth_app_setting_totp_url, headers: @headers

    assert_response :success
  end

  test "should create totp with valid token" do
    with_mocked_totp do |secret|
      get new_auth_app_setting_totp_url, headers: @headers
      token = ROTP::TOTP.new(secret).now

      assert_difference("UserIdentityOneTimePassword.count") do
        post auth_app_setting_totps_url,
             params: { time_based_one_time_password: { first_token: token } },
             headers: @headers
      end

      assert_redirected_to %r{/setting/totps}
    end
  end

  test "should assign attributes to created totp" do
    with_mocked_totp do |secret|
      get new_auth_app_setting_totp_url, headers: @headers
      token = ROTP::TOTP.new(secret).now

      post auth_app_setting_totps_url,
           params: { time_based_one_time_password: { first_token: token } },
           headers: @headers

      created_totp = UserIdentityOneTimePassword.order(created_at: :desc).first

      assert_equal @user, created_totp.user
      assert_not_nil created_totp.last_otp_at
    end
  end

  test "should not create totp with invalid token" do
    get new_auth_app_setting_totp_url, headers: @headers

    assert_no_difference("UserIdentityOneTimePassword.count") do
      post auth_app_setting_totps_url,
           params: { time_based_one_time_password: { first_token: "invalid" } },
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
