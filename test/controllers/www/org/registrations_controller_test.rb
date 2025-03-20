require "test_helper"

class Www::Org::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_org_registration_url
    assert_response :success
  end
end
