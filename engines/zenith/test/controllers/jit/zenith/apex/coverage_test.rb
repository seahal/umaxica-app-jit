# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    require "test_helper"

    class AcmeCoverageTest < ActionDispatch::IntegrationTest
      setup do
        @app_host = ENV.fetch("ZENITH_ACME_APP_URL", "app.localhost")
        @org_host = ENV.fetch("ZENITH_ACME_ORG_URL", "org.localhost")
      end

      test "acme app edge health responds" do
        host! @app_host
        user = users(:one)

        get zenith.acme_app_edge_v0_health_url(ri: "jp"), headers: as_user_headers(user, host: @app_host)

        assert_response :success
        assert_equal "OK", response.parsed_body["status"]
      end

      test "acme org edge health responds" do
        host! @org_host
        staff = staffs(:one)

        get zenith.acme_org_edge_v0_health_url(ri: "jp"), headers: as_staff_headers(staff, host: @org_host)

        assert_response :success
        assert_equal "OK", response.parsed_body["status"]
      end
    end
  end
end
