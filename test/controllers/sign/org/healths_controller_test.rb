# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::HealthsControllerTest < ActionDispatch::IntegrationTest
  test "GET /health returns OK response" do
    get sign_org_health_url(ri: "jp")

    assert_response :success
    assert_includes response.body, "OK"
  end

  test "GET /health returns OK html response" do
    get sign_org_health_url(format: :html, ri: "jp")

    assert_response :success
    assert_includes response.body, "OK"
  end

  test "GET /health returns OK json response" do
    get sign_org_health_url(format: :json, ri: "jp")

    assert_response :success
    assert_includes response.body, "OK"
  end
end
