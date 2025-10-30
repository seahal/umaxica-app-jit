require "test_helper"

class Sign::Org::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_org_registration_url(format: :html), headers: { "Host" => host }

    assert_response :not_found
  end
end
