require "test_helper"

class Www::App::Setting::RecoveryCodesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get www_app_setting_recovery_codes_url
    assert_select "h1", "Www::App::Setting::Recoveries#index"
    assert_select "p", "Find me in app/views/www/app/setting/recoveries/index.html.erb"
    assert_select "a[href=?]",   new_www_app_setting_recovery_code_path
    assert_select "a", "new recovery code"
    assert_response :success
  end

  test "should get new" do
    get new_www_app_setting_recovery_code_url
    assert_select "h1", "Www::App::Setting::Recoveries#new"
    assert_select "p", "Find me in app/views/www/app/setting/recoveries/new.html.erb"
    assert_response :success
  end

  # test "should get show" do
  #   get www_app_setting_recoveries_show_url
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get www_app_setting_recoveries_edit_url
  #   assert_response :success
  # end
end
