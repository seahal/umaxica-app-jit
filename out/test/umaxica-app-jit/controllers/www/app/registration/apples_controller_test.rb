require "test_helper"

class Www::App::Registration::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should get new 2" do
    get new_www_app_registration_apple_url
    assert_select "h1", I18n.t("controller.www.app.registration.apple.new.page_title")
    assert_select "p", "Find me in app/views/net/registration/apples/new.html.erb"
    assert_select "a[href=?]", new_www_app_authentication_apple_path, count: 1
    assert_select "a[href=?]", new_www_app_registration_path, true
    assert_response :success
  end
end
