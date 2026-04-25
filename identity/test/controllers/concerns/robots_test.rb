# typed: false
# frozen_string_literal: true

require "test_helper"

# ---------------------------------------------------------------------------
# Dummy controllers for testing the Robots concern
# ---------------------------------------------------------------------------

class RobotsDummyController < ApplicationController
  include ::Robots

  def index
    show_plain_text
  end
end

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class RobotsConcernTest < ActionDispatch::IntegrationTest
  # ---------------------------------------------------------------------------
  # A. Normal cases
  # ---------------------------------------------------------------------------

  test "returns org surface robots.txt" do
    with_test_routes do
      get "/robots", headers: { "Host" => "org.localhost" }

      assert_response :success
      assert_equal "text/plain", response.media_type
      assert_includes response.body, "User-agent: *"
      assert_includes response.body, "Allow: /"
      assert_includes response.body, "Disallow: /auth"
      assert_includes response.body, "Disallow: /configuration"
      assert_includes response.body, "Disallow: /contacts"
      assert_includes response.body, "Disallow: /edge"
      assert_includes response.body, "Disallow: /emergency"
      assert_includes response.body, "Disallow: /web"
    end
  end

  test "returns app surface robots.txt" do
    with_test_routes do
      get "/robots", headers: { "Host" => "app.localhost" }

      assert_response :success
      assert_equal "text/plain", response.media_type
      assert_includes response.body, "User-agent: *"
      assert_includes response.body, "Allow: /"
      assert_includes response.body, "Disallow: /configuration"
      assert_includes response.body, "Disallow: /contacts"
      assert_includes response.body, "Disallow: /edge"
      assert_includes response.body, "Disallow: /web"
      assert_not response.body.include?("Disallow: /auth"), "App should not have /auth disallow"
    end
  end

  test "returns default robots.txt for com surface" do
    with_test_routes do
      get "/robots", headers: { "Host" => "com.localhost" }

      assert_response :success
      assert_equal "text/plain", response.media_type
      assert_includes response.body, "User-agent: *"
      assert_includes response.body, "Allow: /"
      # Default should have minimal restrictions
      lines = response.body.split("\n")
      # Default should have User-agent, Allow, and empty Disallow
      assert lines.any? { |l| l.include?("User-agent: *") }
      assert lines.any? { |l| l.include?("Allow: /") }
    end
  end

  # ---------------------------------------------------------------------------
  # B. Cache headers
  # ---------------------------------------------------------------------------

  test "sets cache control headers" do
    with_test_routes do
      get "/robots", headers: { "Host" => "app.localhost" }

      assert_response :success
      cache_control = response.headers["Cache-Control"]

      assert_predicate cache_control, :present?
      assert_includes cache_control, "public"
      assert_includes cache_control, "max-age=3600"
      assert_includes cache_control, "s-maxage=86400"
    end
  end

  # ---------------------------------------------------------------------------
  # C. Different hosts
  # ---------------------------------------------------------------------------

  test "handles base.app.localhost host" do
    with_test_routes do
      get "/robots", headers: { "Host" => "base.app.localhost" }

      assert_response :success
      # Should be detected as app surface
      assert_includes response.body, "Disallow: /configuration"
    end
  end

  test "handles sign.app.localhost host" do
    with_test_routes do
      get "/robots", headers: { "Host" => "sign.app.localhost" }

      assert_response :success
      # Should still be app surface
      assert_includes response.body, "Disallow: /configuration"
    end
  end

  test "handles sign.org.localhost host" do
    with_test_routes do
      get "/robots", headers: { "Host" => "sign.org.localhost" }

      assert_response :success
      # Should be org surface
      assert_includes response.body, "Disallow: /auth"
    end
  end

  private

  def with_test_routes
    with_routing do |set|
      set.draw do
        get("/robots", to: "robots_dummy#index")
      end

      yield
    end
  end
end
