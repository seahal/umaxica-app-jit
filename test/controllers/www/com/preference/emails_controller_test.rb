require "test_helper"

class Www::Com::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get new_www_com_preference_email_url
    assert_response :success
  end
end
