require "test_helper"

class Www::Org::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get new_www_org_preference_email_url
    assert_response :success
  end
end
