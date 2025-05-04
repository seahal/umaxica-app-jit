require "test_helper"

class Www::App::Setting::SecurityKeysControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get www_app_setting_passkeys_url
    assert_select "h1", "Www::App::Setting::SecurityKeys#index"
    assert_select "p", "Find me in app/views/www/app/setting/security_keys/index.html.erb"
    assert_response :success
  end

  test "should get new" do
    get new_www_app_setting_passkey_url
    assert_select "h1", "Www::App::Setting::SecurityKeys#new"
    assert_select "p", "Find me in app/views/www/app/setting/security_keys/new.html.erb"
    assert_response :success
  end

  # test "should get show" do
  #   get www_app_setting_security_keys_show_url
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get www_app_setting_security_keys_edit_url
  #   assert_response :success
  # end
end
