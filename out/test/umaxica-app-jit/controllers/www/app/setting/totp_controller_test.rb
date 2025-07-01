require "test_helper"

class Www::App::Registration::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get www_app_setting_totp_index_url
    assert_select "h1", I18n.t("www.app.setting.totp.index.title")
    assert_select "a[href=?]", new_www_app_setting_totp_path
    assert_response :success
  end

  test "should get new" do
    get new_www_app_setting_totp_url
    assert_select "h1", I18n.t("www.app.setting.totp.new.title")
    assert_select "main form div img[alt=?]", "QR Code", count: 1
    assert_select "label[for=?]", "time_based_one_time_password_first_token", count: 1
    assert_select "input[name=?]", "time_based_one_time_password[first_token]", count: 1
    assert_select "input[type=?]", "submit", count: 1
    assert_select "a[href=?]", www_app_setting_totp_index_path
    assert_response :success
  end

  # FIXME: how to implement these line?
  test "should pass totp validation" do
    assert true
  end
end
