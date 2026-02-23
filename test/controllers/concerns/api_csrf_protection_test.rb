# typed: false
# frozen_string_literal: true

require "test_helper"

class TestApiController < ApplicationController
  include ApiCsrfProtection

  def create
    render plain: "OK"
  end
end

class ApiCsrfProtectionTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.routes.draw do
      post "/test_api_csrf", to: "test_api#create"
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
    post "/test_api_csrf", headers: { "Origin" => "http://evil.com" }
    assert_response :unprocessable_content
  end

  test "rejects request with subdomain Origin (Strict Mode)" do
    post "/test_api_csrf", headers: { "Origin" => "http://sub.www.example.com" }
    assert_response :unprocessable_content
  end

  test "rejects request with invalid Origin URI" do
    post "/test_api_csrf", headers: { "Origin" => "::::" }
    assert_response :unprocessable_content
  end

  test "rejects request with non-http scheme" do
    post "/test_api_csrf", headers: { "Origin" => "file://etc/passwd" }
    assert_response :unprocessable_content
  end
end
