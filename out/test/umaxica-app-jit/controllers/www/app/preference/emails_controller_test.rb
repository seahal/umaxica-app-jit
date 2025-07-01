require "test_helper"

class Www::App::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get new_www_app_preference_email_url
    assert_response :success
  end
end
