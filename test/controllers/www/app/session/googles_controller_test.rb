require "test_helper"

class Www::App::Session::GooglesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_session_google_url
    assert_response :success
  end
end
