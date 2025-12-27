# frozen_string_literal: true

require "test_helper"

class Auth::Org::AuthenticationControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_org_authentication_url

    assert_response :success
  end
end
