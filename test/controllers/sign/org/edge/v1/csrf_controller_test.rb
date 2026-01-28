# frozen_string_literal: true

require "test_helper"

class Sign::Org::Edge::V1::CsrfControllerTest < ActionDispatch::IntegrationTest
  test "returns csrf token payload" do
    get sign_org_edge_v1_csrf_url(ri: "jp")

    assert_response :success
    assert_not response.parsed_body["csrf_token"].to_s.empty?
  end
end
