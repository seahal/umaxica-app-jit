# frozen_string_literal: true

require "test_helper"

class Auth::Org::V1::CsrfControllerTest < ActionDispatch::IntegrationTest
  test "returns csrf token payload" do
    get auth_org_v1_csrf_url

    assert_response :success
    assert_not response.parsed_body["csrf_token"].to_s.empty?
  end
end
