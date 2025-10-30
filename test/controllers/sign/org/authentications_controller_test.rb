require "test_helper"

class Sign::Org::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_org_authentication_url, headers: { "Host" => ENV["SIGN_STAFF_URL"] }

    assert_response :success
  end

  test "should respond to delete action" do
    # Test that the controller has a delete action
    assert_includes Sign::Org::AuthenticationsController.instance_methods, :delete
  end
end
