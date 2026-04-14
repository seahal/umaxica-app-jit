# typed: false
# frozen_string_literal: true

require "test_helper"

class ApexCoverageTest < ActionDispatch::IntegrationTest
  setup do
    @app_host = ENV.fetch("APEX_SERVICE_URL", "app.localhost")
    @org_host = ENV.fetch("APEX_STAFF_URL", "org.localhost")
  end

  test "apex app edge health responds" do
    host! @app_host
    user = users(:one)

    get apex_app_edge_v0_health_url(ri: "jp"), headers: as_user_headers(user, host: @app_host)

    assert_response :success
    assert_equal "OK", response.parsed_body["status"]
  end

  test "apex org edge health responds" do
    host! @org_host
    staff = staffs(:one)

    get apex_org_edge_v0_health_url(ri: "jp"), headers: as_staff_headers(staff, host: @org_host)

    assert_response :success
    assert_equal "OK", response.parsed_body["status"]
  end
end
