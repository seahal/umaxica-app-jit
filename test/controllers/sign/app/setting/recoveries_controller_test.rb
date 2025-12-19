# frozen_string_literal: true

require "test_helper"

module Sign
  module App
    module Setting
      class RecoveriesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @user = User.create!(public_id: "user_#{SecureRandom.hex(8)}", user_identity_status_id: "ALIVE")
          @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
        end

        test "should get index" do
          get sign_app_setting_recoveries_url, headers: @headers

          assert_response :success
        end

        test "should get new" do
          get new_sign_app_setting_recovery_url, headers: @headers

          assert_response :success
          assert_not_nil session[:user_recovery_code]
        end

        test "should create recovery code" do
          # Visit new to set the session
          get new_sign_app_setting_recovery_url, headers: @headers

          assert_difference("UserRecoveryCode.count") do
            post sign_app_setting_recoveries_url, params: {
              user_recovery_code: { confirm_create_recovery_code: "1" }
            }, headers: @headers
          end

          assert_redirected_to sign_app_setting_recovery_url(UserRecoveryCode.last, regional_defaults)
        end

        test "should show recovery code" do
          recovery_code = UserRecoveryCode.create!(
            user: @user,
            recovery_code_digest: "digest",
            expires_in: 1.day.from_now
          )
          get sign_app_setting_recovery_url(recovery_code), headers: @headers

          assert_response :success
        end

        test "should destroy recovery code" do
          recovery_code = UserRecoveryCode.create!(user: @user, recovery_code_digest: "digest")

          assert_difference("UserRecoveryCode.count", -1) do
            delete sign_app_setting_recovery_url(recovery_code), headers: @headers
          end

          assert_redirected_to sign_app_setting_recoveries_url(regional_defaults)
        end

        private

        def regional_defaults
          PreferenceConstants::DEFAULT_PREFERENCES.transform_keys(&:to_sym)
        end
      end
    end
  end
end
