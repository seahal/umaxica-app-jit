require "test_helper"

class Www::App::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_authentication_url
    assert_response :success
    # assert_select "a[href=?]", new_app_session_email_path
    # assert_select "a[href=?]", new_app_session_apple_path
    # assert_select "a[href=?]", new_app_session_google_path
    # assert_select "a[href=?]", new_app_session_passkey_path
    # assert_select "a[href=?]", new_app_session_password_path
    # assert_select "a[href=?]", new_app_registration_path
    # assert_select "a[href=?]", www_app_root_path, count: 2
  end

  test "should get edit" do
    get edit_www_app_authentication_url
    assert_response :success
    refute nil
  end

  test "should get delete" do
    refute false
  end
end
