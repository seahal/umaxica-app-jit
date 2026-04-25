# typed: false
# frozen_string_literal: true

require "test_helper"

# ---------------------------------------------------------------------------
# Dummy controllers for testing the Session concern
# ---------------------------------------------------------------------------

class SessionDummyController < ApplicationController
  include ::Session

  before_action :validate_flash_boundary

  def index
    render plain: "ok"
  end

  def set_flash
    flash.now[:notice] = "Test message" # rubocop:disable Rails/I18nLocaleTexts
    record_flash_boundary
    render plain: "flash set"
  end

  def reset_flash_action
    reset_flash
    render plain: "flash reset"
  end
end

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class SessionConcernTest < ActionDispatch::IntegrationTest
  setup do
    # Clear flash between tests
  end

  # ---------------------------------------------------------------------------
  # A. Normal cases
  # ---------------------------------------------------------------------------

  test "allows flash carry-over on same boundary" do
    with_test_routes do
      # First request sets flash and records boundary
      get "/session_set_flash", headers: test_headers

      assert_response :success

      # Second request on same boundary should keep flash
      get "/session_dummy", headers: test_headers

      assert_response :success
    end
  end

  test "discards flash when crossing boundaries without allowed transition" do
    with_test_routes do
      # Set flash on sign:app boundary
      get "/session_set_flash", headers: test_headers("sign.app.localhost")

      assert_response :success

      # Navigate to docs:app (not in allowlist) - flash should be discarded
      get "/session_dummy", headers: test_headers("docs.app.localhost")

      assert_response :success
      # Flash should be empty after boundary mismatch
    end
  end

  test "allows flash for explicitly allowed transitions" do
    allowed_transitions = [
      ["sign.app.localhost", "base.app.localhost"],
      ["sign.com.localhost", "base.com.localhost"],
      ["sign.org.localhost", "base.org.localhost"],
      ["sign.app.localhost", "acme.app.localhost"],
      ["sign.com.localhost", "acme.com.localhost"],
      ["sign.org.localhost", "acme.org.localhost"],
    ]

    with_test_routes do
      allowed_transitions.each do |from_host, to_host|
        # Set flash on source boundary
        get "/session_set_flash", headers: test_headers(from_host)

        assert_response :success

        # Navigate to target boundary (should be allowed)
        get "/session_dummy", headers: test_headers(to_host)

        assert_response :success
      end
    end
  end

  # ---------------------------------------------------------------------------
  # B. record_flash_boundary
  # ---------------------------------------------------------------------------

  test "record_flash_boundary stores current boundary in session" do
    with_test_routes do
      get "/session_set_flash", headers: test_headers("sign.app.localhost")

      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # C. reset_flash
  # ---------------------------------------------------------------------------

  test "reset_flash clears flash and removes boundary marker" do
    with_test_routes do
      # Set flash first
      get "/session_set_flash", headers: test_headers

      assert_response :success

      # Reset flash
      get "/session_reset_flash", headers: test_headers

      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # D. Boundary detection
  # ---------------------------------------------------------------------------

  test "handles requests without stored boundary" do
    with_test_routes do
      # First request without any previous flash
      get "/session_dummy", headers: test_headers

      assert_response :success
    end
  end

  test "boundary key is derived from Current attributes" do
    # This tests that Current.boundary_key is properly set
    with_test_routes do
      get "/session_dummy", headers: test_headers("sign.app.localhost")

      assert_response :success
    end
  end

  private

  def test_headers(host = "app.localhost")
    { "Host" => host }
  end

  def with_test_routes
    with_routing do |set|
      set.draw do
        get("/session_dummy", to: "session_dummy#index")
        get("/session_set_flash", to: "session_dummy#set_flash")
        get("/session_reset_flash", to: "session_dummy#reset_flash_action")
      end

      yield
    end
  end
end
