# frozen_string_literal: true

require "test_helper"

class Sign::App::Setting::RecoveriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "should get index" do
    get sign_app_setting_recoveries_url, headers: { "Host" => @host }

    assert_response :success
  end

  test "should get new" do
    get new_sign_app_setting_recovery_url, headers: { "Host" => @host }

    assert_response :success
  end

  test "should not create user_recovery_code without confirmation" do
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
end
