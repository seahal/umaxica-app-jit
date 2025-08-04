require "test_helper"

class Auth::App::Authentication::TelephonesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_authentication_telephone_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_response :success
    assert_select "a[href=?]", new_auth_app_authentication_path, I18n.t("www.app.authentication.new.back")
  end
end
