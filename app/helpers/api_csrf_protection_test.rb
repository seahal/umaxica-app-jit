# frozen_string_literal: true

require "test_helper"

class ApiCsrfProtectionTest < ActionDispatch::IntegrationTest
  # Dummy controller to test the concern
  class TestApiController < ApplicationController
    include ApiCsrfProtection

    # Mock CSRF token verification to isolate Origin check
    # In real app, this would be protect_from_forgery
    def create
      render plain: "OK"
    end
  end

  setup do
    Rails.application.routes.draw do
      post "/test_api_csrf", to: "api_csrf_protection_test/test_api_controller#create"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "allows request with no Origin (falls back to token check)" do
    post "/test_api_csrf"
    assert_response :success
  end

  test "allows request with matching Origin" do
    post "/test_api_csrf", headers: { "Origin" => "http://www.example.com" }
    assert_response :success
  end

  test "rejects request with mismatched Origin" do
    assert_raises(ActionController::InvalidCrossOriginRequest) do
      post "/test_api_csrf", headers: { "Origin" => "http://evil.com" }
    end
  end

  test "rejects request with subdomain Origin (Strict Mode)" do
    assert_raises(ActionController::InvalidCrossOriginRequest) do
      post "/test_api_csrf", headers: { "Origin" => "http://sub.www.example.com" }
    end
  end

  test "rejects request with invalid Origin URI" do
    assert_raises(ActionController::InvalidCrossOriginRequest) do
      post "/test_api_csrf", headers: { "Origin" => "::::" }
    end
  end

  test "rejects request with non-http scheme" do
    assert_raises(ActionController::InvalidCrossOriginRequest) do
      post "/test_api_csrf", headers: { "Origin" => "file://etc/passwd" }
    end
  end
end
