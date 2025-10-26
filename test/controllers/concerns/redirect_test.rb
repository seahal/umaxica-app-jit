# frozen_string_literal: true

require "test_helper"

class RedirectConcernTest < ActionDispatch::IntegrationTest
  class TestController < ApplicationController
    include Redirect

    def test_generate
      result = generate_redirect_url(params[:url])
      render json: { encoded: result }
    end

    def test_jump
      jump_to_generated_url(params[:encoded_url])
    end

    def test_allowed
      result = allowed_host?(params[:host])
      render json: { allowed: result }
    end
  end

  setup do
    @controller = TestController.new
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      get "test_generate" => "redirect_concern_test/test#test_generate"
      get "test_jump" => "redirect_concern_test/test#test_jump"
      get "test_allowed" => "redirect_concern_test/test#test_allowed"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "normalize_host removes scheme and returns host" do
    assert_equal "example.com", Redirect.normalize_host("https://example.com")
    assert_equal "example.com", Redirect.normalize_host("http://example.com")
    assert_equal "example.com", Redirect.normalize_host("example.com")
  end

  test "normalize_host handles nil and blank values" do
    assert_nil Redirect.normalize_host(nil)
    assert_nil Redirect.normalize_host("")
    assert_nil Redirect.normalize_host("  ")
  end

  test "normalize_host removes paths" do
    assert_equal "example.com", Redirect.normalize_host("https://example.com/path/to/page")
    assert_equal "example.com", Redirect.normalize_host("example.com/path")
  end

  test "normalize_host handles symbols" do
    assert_equal "example.com", Redirect.normalize_host(:"https://example.com")
  end

  test "normalize_host strips whitespace" do
    assert_equal "example.com", Redirect.normalize_host("  https://example.com  ")
  end

  test "normalize_host is case insensitive" do
    assert_equal "example.com", Redirect.normalize_host("HTTPS://EXAMPLE.COM")
    assert_equal "example.com", Redirect.normalize_host("Example.Com")
  end

  test "normalize_host handles invalid URIs gracefully" do
    result = Redirect.normalize_host("ht!tp://bad-url")
    assert_equal "ht!tp:", result
  end

  test "allowed_host? returns false for nil" do
    get test_allowed_url, params: { host: nil }
    result = response.parsed_body
    assert_equal false, result["allowed"]
  end

  test "allowed_host? returns false for blank" do
    get test_allowed_url, params: { host: "" }
    result = response.parsed_body
    assert_equal false, result["allowed"]
  end

  test "generate_redirect_url returns nil for blank URL" do
    get test_generate_url, params: { url: "" }
    result = response.parsed_body
    assert_nil result["encoded"]
  end

  test "generate_redirect_url returns nil for nil URL" do
    get test_generate_url, params: { url: nil }
    result = response.parsed_body
    assert_nil result["encoded"]
  end

  test "jump_to_generated_url redirects to root when encoded_url is blank" do
    get test_jump_url, params: { encoded_url: "" }
    assert_redirected_to "/"
  end

  test "jump_to_generated_url returns not_found for invalid base64" do
    get test_jump_url, params: { encoded_url: "invalid-base64!" }
    assert_response :not_found
  end

  test "ALLOWED_HOSTS constant is frozen" do
    assert Redirect::ALLOWED_HOSTS.frozen?
  end

  test "ALLOWED_HOSTS is an array" do
    assert_instance_of Array, Redirect::ALLOWED_HOSTS
  end

  private

  def test_generate_url
    "http://test.localhost/test_generate"
  end

  def test_jump_url
    "http://test.localhost/test_jump"
  end

  def test_allowed_url
    "http://test.localhost/test_allowed"
  end
end
