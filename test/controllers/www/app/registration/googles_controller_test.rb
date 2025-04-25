require "test_helper"

class Www::App::Registration::GooglesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_registration_google_url
    assert_response :success
  end
end
