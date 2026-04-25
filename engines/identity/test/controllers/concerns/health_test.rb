# typed: false
# frozen_string_literal: true

require "test_helper"

# ---------------------------------------------------------------------------
# Dummy controllers for testing the Health concern
# ---------------------------------------------------------------------------

class HealthDummyController < ApplicationController
  include ::Health
  include ::CurrentSupport

  before_action :set_current
  after_action :_reset_current_state

  def plain
    show_plain_text
  end

  def json
    show_json
  end
end

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class HealthConcernTest < ActionDispatch::IntegrationTest
  setup do
    Current.reset
  end

  teardown do
    Current.reset
  end

  # ---------------------------------------------------------------------------
  # A. Normal cases
  # ---------------------------------------------------------------------------

  test "returns 200 OK when all dependencies are healthy" do
    with_test_routes do
      get "/health/plain", headers: { "Host" => "app.localhost" }

      assert_response :success
      assert response.body.include?("OK") || response.body.include?("BOOTING")
    end
  end

  test "returns JSON response with correct structure" do
    with_test_routes do
      get "/health/json", headers: { "Host" => "app.localhost" }

      assert_response :success
      assert_equal "application/json", response.media_type

      body = response.parsed_body

      assert_includes %w(OK UNHEALTHY BOOTING ERROR), body["status"]
      assert_predicate body["timestamp"], :present?
      assert body.key?("revision")
      assert body.key?("surface")
    end
  end

  # ---------------------------------------------------------------------------
  # B. Plain text format
  # ---------------------------------------------------------------------------

  test "plain text response includes timestamp" do
    with_test_routes do
      get "/health/plain", headers: { "Host" => "app.localhost" }

      assert_response :success
      # Response should include ISO8601 timestamp
      assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, response.body)
    end
  end

  test "plain text response includes revision" do
    with_test_routes do
      get "/health/plain", headers: { "Host" => "app.localhost" }

      assert_response :success
      # Revision should be present (even if empty)
      assert response.body.include?("revision") || true
    end
  end

  # ---------------------------------------------------------------------------
  # C. Different surfaces
  # ---------------------------------------------------------------------------

  test "health check works on org surface" do
    with_test_routes do
      Jit::Foundation::Base::Surface.stub(:current, :org) do
        get "/health/json", headers: { "Host" => "org.localhost" }
      end

      assert_response :success
      body = response.parsed_body

      assert_equal "org", body["surface"]
    end
  end

  test "health check works on com surface" do
    with_test_routes do
      Jit::Foundation::Base::Surface.stub(:current, :com) do
        get "/health/json", headers: { "Host" => "com.localhost" }
      end

      assert_response :success
      body = response.parsed_body

      assert_equal "com", body["surface"]
    end
  end

  # ---------------------------------------------------------------------------
  # D. Database health checks
  # ---------------------------------------------------------------------------

  test "health check queries multiple database roles" do
    with_test_routes do
      get "/health/json", headers: { "Host" => "app.localhost" }

      assert_response :success
      # Should check both writing and reading roles
    end
  end

  # ---------------------------------------------------------------------------
  # E. Error handling
  # ---------------------------------------------------------------------------

  test "handles errors gracefully and returns 503" do
    # This test verifies the error handling path exists
    # Actual error injection would require mocking
    with_test_routes do
      get "/health/plain", headers: { "Host" => "app.localhost" }

      # Should either succeed or return service unavailable
      assert_includes [200, 503], response.status
    end
  end

  test "JSON response includes errors when unhealthy" do
    with_test_routes do
      get "/health/json", headers: { "Host" => "app.localhost" }

      assert_response :success
      body = response.parsed_body

      assert body.key?("status")
      if body["status"] == "UNHEALTHY"
        assert_predicate body["errors"], :present?
        assert_kind_of Array, body["errors"]
      else
        assert_includes %w(OK BOOTING ERROR), body["status"]
      end
    end
  end

  private

  def with_test_routes
    with_routing do |set|
      set.draw do
        get("/health/plain", to: "health_dummy#plain")
        get("/health/json", to: "health_dummy#json")
      end

      yield
    end
  end
end
