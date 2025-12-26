# frozen_string_literal: true

require "test_helper"

class RedirectConcernTest < ActiveSupport::TestCase
  include Redirect

  # Mock ENV variables for testing by overriding the method
  def allowed_hosts
    ["example.com", "trusted.jp"]
  end

  test "allowed_host? allows exact match" do
    assert allowed_host?("example.com")
    assert allowed_host?("trusted.jp")
  end

  test "allowed_host? allows subdomains" do
    assert allowed_host?("sub.example.com")
    assert allowed_host?("deep.sub.trusted.jp")
  end

  test "allowed_host? denies partial match suffix" do
    assert_not allowed_host?("evilexample.com")
    assert_not allowed_host?("nottrusted.jp")
  end

  test "allowed_host? denies unrelated hosts" do
    assert_not allowed_host?("google.com")
    assert_not allowed_host?("evil.com")
  end

  test "allowed_host? denies empty or nil" do
    assert_not allowed_host?(nil)
    assert_not allowed_host?("")
  end

  test "generate_redirect_url returns nil for disallowed hosts" do
    assert_nil generate_redirect_url("http://evil.com")
  end

  test "generate_redirect_url returns encoded url for allowed hosts" do
    url = "https://sub.example.com/path?query=1"
    encoded = generate_redirect_url(url)

    assert_not_nil encoded
    assert_equal url, Base64.urlsafe_decode64(encoded)
  end

  test "generate_redirect_url denies non-http schemes" do
    assert_nil generate_redirect_url("javascript:alert(1)")
    assert_nil generate_redirect_url("file:///etc/passwd")
  end

  test "generate_redirect_url denies urls with userinfo" do
    assert_nil generate_redirect_url("https://user:pass@example.com")
    assert_nil generate_redirect_url("https://:pass@example.com")
    assert_nil generate_redirect_url("https://user@example.com")
  end

  test "generate_redirect_url denies urls with control characters" do
    assert_nil generate_redirect_url("https://example.com/\n")
    assert_nil generate_redirect_url("https://example.com/\r")
  end
end
