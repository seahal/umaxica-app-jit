require "test_helper"

class Auth::Org::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_org_authentication_url, headers: { "Host" => ENV["SIGN_STAFF_URL"] }

    assert_response :success
  end

  test "should respond to destroy action" do
    # Test that the controller has a destroy action
    assert_includes Auth::Org::AuthenticationsController.instance_methods, :destroy
  end
end
