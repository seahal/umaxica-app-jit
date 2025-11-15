# frozen_string_literal: true

require "test_helper"

module Sign::App::Setting
  class RecoveriesControllerTest < ActionDispatch::IntegrationTest
    # TODO: Uncomment when routes and UserRecoveryCode model are available
    # setup do
    #   @user = users(:one)
    # end
    #
    # test "should get index" do
    #   get sign_app_setting_recoveries_url
    #
    #   assert_response :success
    # end
    #
    # test "should get new" do
    #   get new_sign_app_setting_recovery_url
    #
    #   assert_response :success
    #   assert_not_nil session[:user_recovery_code]
    # end
    #
    # test "should create user recovery code" do
    #   post sign_app_setting_recoveries_url, params: {
    #     user_recovery_code: {
    #       confirm_create_recovery_code: "1"
    #     }
    #   }
    #
    #   assert_response :redirect
    # end
    #
    # test "should get show" do
    #   recovery_code = UserRecoveryCode.create!(
    #     user_id: @user.id,
    #     recovery_code_digest: "test_digest"
    #   )
    #
    #   get sign_app_setting_recovery_url(recovery_code)
    #
    #   assert_response :success
    # end
    #
    # test "should get edit" do
    #   recovery_code = UserRecoveryCode.create!(
    #     user_id: @user.id,
    #     recovery_code_digest: "test_digest"
    #   )
    #
    #   get edit_sign_app_setting_recovery_url(recovery_code)
    #
    #   assert_response :success
    # end
    #
    # test "should update user recovery code" do
    #   recovery_code = UserRecoveryCode.create!(
    #     user_id: @user.id,
    #     recovery_code_digest: "test_digest"
    #   )
    #
    #   patch sign_app_setting_recovery_url(recovery_code), params: {
    #     user_recovery_code: {
    #       confirm_create_recovery_code: "1"
    #     }
    #   }
    #
    #   assert_response :redirect
    # end
    #
    # test "should destroy user recovery code" do
    #   recovery_code = UserRecoveryCode.create!(
    #     user_id: @user.id,
    #     recovery_code_digest: "test_digest"
    #   )
    #
    #   assert_difference("UserRecoveryCode.count", -1) do
    #     delete sign_app_setting_recovery_url(recovery_code)
    #   end
    #
    #   assert_response :see_other
    # end
  end
end
