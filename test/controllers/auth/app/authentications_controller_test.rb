require "test_helper"

class Auth::App::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_authentication_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_response :success
    assert_select "a[href=?]", new_auth_app_authentication_email_path
    assert_select "a[href=?]", new_auth_app_authentication_telephone_path
    assert_select "a[href=?]", new_auth_app_authentication_apple_path
    assert_select "a[href=?]", new_auth_app_authentication_google_path
    assert_select "a[href=?]", new_auth_app_authentication_passkey_path
    assert_select "a[href=?]", new_auth_app_authentication_recovery_path
    assert_select "a[href=?]", new_auth_app_registration_path
  end
  //
  test "should get edit" do
    skip
    get edit_auth_app_authentication_url
    assert_response :internal_server_error
    assert_select "h1", I18n.t("www.app.authentication.edit.title")
  end

  test "should not get edit when not logged in" do
    skip
    get edit_auth_app_authentication_url
    assert_response :internal_server_error
    assert_select "h1", I18n.t("www.app.authentication.edit.title")
  end
end
