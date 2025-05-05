require "test_helper"

class Www::App::Registration::GooglesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_registration_google_url
    assert_select "h1", I18n.t("www.app.registration.google.new.page_title")
    assert_select "p", "Find me in app/views/net/registration/googles/new.html.erb"
    assert_select "a[href=?]", new_www_app_authentication_google_path, count: 1
    assert_select "a[href=?]", new_www_app_registration_path
    assert_response :success
  end
end
