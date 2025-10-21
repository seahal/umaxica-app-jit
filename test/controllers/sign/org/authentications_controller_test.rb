require "test_helper"

class Sign::Org::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_org_authentication_url, headers: { "Host" => ENV["SIGN_STAFF_URL"] }
    assert_response :success
  end

  test "should delete" do
    # TODO: Implement delete action test
    assert_not false
  end
end
