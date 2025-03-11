require "test_helper"

class Www::Org::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get www_org_registrations_new_url
    assert_response :success
  end
end
