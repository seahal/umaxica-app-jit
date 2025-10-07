require "test_helper"

class Auth::App::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_registration_url(format: :html), headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_response :success
  end


  test "should get html which must have html which contains lang param." do
    get new_auth_app_registration_url(format: :html)
    assert_response :success
    assert_select("html[lang=?]", "ja")
    assert_not_select("html[lang=?]", "")
  end
end
