# frozen_string_literal: true

require "test_helper"


class Sign::App::Setting::RecoveriesControllerAdditionalTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = User.first || User.create!(id: SecureRandom.uuid_v7)
  end

  test "GET index lists all user recovery codes" do
    get sign_app_setting_recoveries_url, headers: { "Host" => @host }

    assert_response :success
  end

  test "GET new generates recovery code in session" do
    get new_sign_app_setting_recovery_url, headers: { "Host" => @host }

    assert_response :success
    assert_not_nil session[:user_recovery_code]
    assert_equal 24, session[:user_recovery_code].length
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "POST create with confirmation saves recovery code" do
    get new_sign_app_setting_recovery_url, headers: { "Host" => @host }
    recovery_code = session[:user_recovery_code]

    assert_difference("UserRecoveryCode.count", 1) do
      post sign_app_setting_recoveries_url,
           params: {
             user_recovery_code: {
               confirm_create_recovery_code: "1"
             }
           },
           headers: { "Host" => @host }
    end

    assert_response :redirect
    follow_redirect!

    assert_response :success
    assert_equal I18n.t("messages.user_recovery_code_successfully_created"), flash[:notice]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "POST create without confirmation renders new with unprocessable status" do
    get new_sign_app_setting_recovery_url, headers: { "Host" => @host }

    assert_no_difference("UserRecoveryCode.count") do
      post sign_app_setting_recoveries_url,
           params: {
             user_recovery_code: {
               confirm_create_recovery_code: "0"
             }
           },
           headers: { "Host" => @host }
    end

    assert_response :unprocessable_content
  end

  test "generate_base58_string creates 24 character string from BASE58 alphabet" do
    get new_sign_app_setting_recovery_url, headers: { "Host" => @host }
    recovery_code = session[:user_recovery_code]

    assert_equal 24, recovery_code.length
    # Verify all characters are from BASE58 alphabet
    base58_chars = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    recovery_code.each_char do |char|
      assert_includes base58_chars, char
    end
  end

  test "multiple calls to new generate different recovery codes" do
    get new_sign_app_setting_recovery_url, headers: { "Host" => @host }
    first_code = session[:user_recovery_code]

    get new_sign_app_setting_recovery_url, headers: { "Host" => @host }
    second_code = session[:user_recovery_code]

    assert_not_equal first_code, second_code
  end

  # test "recovery code is hashed with argon2 before saving" do
  #   get new_sign_app_setting_recovery_url, headers: { "Host" => @host }
  #   plain_code = session[:user_recovery_code]

  #   post sign_app_setting_recoveries_url,
  #        params: {
  #          user_recovery_code: {
  #            confirm_create_recovery_code: "1"
  #          }
  #        },
  #        headers: { "Host" => @host }

  #   saved_code = UserRecoveryCode.last
  #   assert_not_equal plain_code, saved_code.recovery_code_digest
  #   # Argon2 hashes start with $argon2 prefix
  #   assert saved_code.recovery_code_digest.include?("argon2"), "Recovery code digest should be hashed with Argon2"
  # end
end

