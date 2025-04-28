require "test_helper"

class Www::App::Registration::TelephonesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_registration_telephone_url
    assert_response :success
  end
end
