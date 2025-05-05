require "test_helper"

class Www::App::Session::PasskeysControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_authentication_passkey_url
    assert_response :success
    assert_select "a[href=?]", new_www_app_authentication_path, I18n.t('www.app.authentication.new.back')
  end
end
