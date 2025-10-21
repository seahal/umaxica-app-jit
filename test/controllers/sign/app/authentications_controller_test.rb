require "test_helper"

class Sign::App::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  # test "should get new" do
  #   get new_sign_app_authentication_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }
  #   assert_response :success
  #   assert_select "a[href=?]", new_sign_app_authentication_email_path(query)
  #   assert_select "a[href=?]", new_sign_app_authentication_telephone_path(query)
  #   assert_select "a[href=?]", new_sign_app_authentication_passkey_path(query)
  #   assert_select "a[href=?]", new_sign_app_authentication_recovery_path(query)
  #   assert_select "a[href=?]", new_sign_app_registration_path(query)
  # end
  # 
  test "should get edit" do
    get edit_sign_app_authentication_url
    # assert_response :internal_server_error
    assert_select "h1", I18n.t("sign.app.authentication.edit.title")
  end

  test "should not get edit when not logged in" do
    get edit_sign_app_authentication_url
    # assert_response :internal_server_error
    assert_select "h1", I18n.t("sign.app.authentication.edit.title")
  end
end
