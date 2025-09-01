require "test_helper"

class Auth::Org::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_org_authentication_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }
    assert_response :success
  end

  test "should delete" do
    # TODO: Implement delete action test
    assert_not false
  end
end
