require "test_helper"

class Www::App::SettingControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get www_app_setting_url
    assert_select "h1", "Www::App::Setting#show"
    assert_select "p", "Find me in app/views/www/app/setting/show.html.erb"
    assert_select "a[href=?]", auth_app_setting_totps_url
    assert_select "a", "TOTP"
    assert_select "a[href=?]", auth_app_setting_passkeys_url
    assert_select "a", "PASSKEY"
    assert_select "a[href=?]", auth_app_setting_recoveries_url
    assert_select "a", "RECOVERY CODE"
    assert_response :success
  end
end
