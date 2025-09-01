# frozen_string_literal: true

require "test_helper"

class Auth::App::Setting::RecoveriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["AUTH_SERVICE_URL"] || "auth.app.localhost"
  end

  test "should get index" do
    get auth_app_setting_recoveries_url, headers: { "Host" => @host }
    assert_response :success
  end

  test "should get new" do
    get new_auth_app_setting_recovery_url, headers: { "Host" => @host }
    assert_response :success
  end

  # test "should not create user_recovery_code without confirmation" do
  #   assert_no_difference("UserRecoveryCode.count") do
  #     post auth_app_setting_recoveries_url,
  #          params: {
  #            user_recovery_code: {
  #              confirm_create_recovery_code: "1"
  #            }
  #          },
  #          headers: { "Host" => @host }
  #   end
  #
  #   assert_response :unprocessable_content
  # end
end
