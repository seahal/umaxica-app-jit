require "test_helper"

class Apex::Com::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_com_preference_email_url
    assert_response :success
  end

  # test "should update email preferences with valid params" do
  #   patch apex_com_preference_email_url, params: {
  #     newsletter: true,
  #     product_updates: false,
  #     security_alerts: true,
  #     promotional: false
  #   }
  #   assert_response :redirect
  #   assert_equal "メール設定が正常に更新されました", flash[:notice]
  # end

  # test "should handle update with no params" do
  #   patch apex_com_preference_email_url
  #   assert_response :unprocessable_content
  #   assert_equal "設定が選択されていません", flash[:alert]
  # end
end
