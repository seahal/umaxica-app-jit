# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Acme::App::HealthsControllerTest < ActionDispatch::IntegrationTest
      test "GET /health returns OK response without redirect" do
        host! ENV["ZENITH_ACME_APP_URL"] || "app.localhost"

        get zenith.acme_app_health_url(ri: "jp"), headers: browser_headers

        assert_response :success
        assert_not_predicate response, :redirect?
        assert_equal "text/plain; charset=utf-8", response.headers["Content-Type"]
        assert_includes response.body, "OK"
      end
    end
  end
end
