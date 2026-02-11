# frozen_string_literal: true

require "test_helper"

class Common::RedirectTest < ActiveSupport::TestCase
  test "normalize_host returns nil for blank values" do
    assert_nil Common::Redirect.normalize_host(nil)
    assert_nil Common::Redirect.normalize_host("")
    assert_nil Common::Redirect.normalize_host("   ")
  end

  test "normalize_host extracts host from URL" do
    assert_equal "example.com", Common::Redirect.normalize_host("https://example.com/path")
    assert_equal "example.com", Common::Redirect.normalize_host("http://example.com")
    assert_equal "example.com", Common::Redirect.normalize_host("example.com/path")
  end

  test "normalize_host handles invalid URIs" do
    assert_equal "not a url", Common::Redirect.normalize_host("not a url")
  end

  test "normalize_host downcases host" do
    assert_equal "example.com", Common::Redirect.normalize_host("HTTPS://EXAMPLE.COM")
  end
end
