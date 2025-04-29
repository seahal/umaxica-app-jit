require "test_helper"

class Www::App::Session::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_authentication_email_url
    assert_select "h1", I18n.t('www.app.authentication.email.new.page_title')
    assert_select "a", I18n.t('www.app.authentication.new.back')
    assert_select "a[href=?]", new_www_app_authentication_path
    assert_not cookies[:htop_private_key].nil?
    assert_response :success
  end

  # FIXME: implement this test
  test "reject already logged in user" do
    get new_www_app_authentication_email_url
    assert_response :success
  end

  # FIXME: implement this test
  test "reject already logged in staff" do
    get new_www_app_authentication_email_url
    assert_response :success
  end
end
