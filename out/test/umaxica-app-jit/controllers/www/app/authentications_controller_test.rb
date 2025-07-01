require "test_helper"

class Www::App::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_authentication_url
    assert_response :success
    assert_select "a[href=?]", new_www_app_authentication_email_path
    assert_select "a[href=?]", new_www_app_authentication_telephone_path
    assert_select "a[href=?]", new_www_app_authentication_apple_path
    assert_select "a[href=?]", new_www_app_authentication_google_path
    assert_select "a[href=?]", new_www_app_authentication_passkey_path
    assert_select "a[href=?]", new_www_app_authentication_recovery_code_path
    assert_select "a[href=?]", new_www_app_registration_path
  end

  test "should get edit" do
    get edit_www_app_authentication_url
    assert_response :success
    assert_select "h1", I18n.t("www.app.authentication.edit.title")
  end

  test "should get delete" do
    refute false
  end
end
