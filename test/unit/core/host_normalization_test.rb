# typed: false
# frozen_string_literal: true

require "test_helper"

module Core
  class HostNormalizationTest < ActiveSupport::TestCase
    test "normalize returns nil for blank input" do
      assert_nil HostNormalization.normalize(nil)
      assert_nil HostNormalization.normalize("")
      assert_nil HostNormalization.normalize("   ")
    end

    test "normalize extracts host from full URL with protocol, port, and path" do
      assert_equal "example.com", HostNormalization.normalize("https://example.com:8080/path")
      assert_equal "example.com", HostNormalization.normalize("http://example.com:80/path?q=1")
    end

    test "normalize extracts host from protocol-relative URL" do
      result = HostNormalization.normalize("//example.com/path")

      assert result.nil? || result == "example.com"
    end

    test "normalize extracts host from plain host string" do
      assert_equal "example.com", HostNormalization.normalize("example.com")
    end

    test "normalize downcases the host" do
      assert_equal "example.com", HostNormalization.normalize("EXAMPLE.COM")
      assert_equal "example.com", HostNormalization.normalize("https://EXAMPLE.COM/path")
    end

    test "normalize removes trailing dot" do
      assert_equal "example.com", HostNormalization.normalize("example.com.")
      assert_equal "example.com", HostNormalization.normalize("https://example.com./path")
    end

    test "normalize handles host with port only" do
      assert_equal "example.com", HostNormalization.normalize("example.com:3000")
    end

    test "normalize handles localhost" do
      assert_equal "localhost", HostNormalization.normalize("localhost")
      assert_equal "localhost", HostNormalization.normalize("http://localhost:3000")
    end

    test "normalize handles subdomain" do
      assert_equal "sub.example.com", HostNormalization.normalize("https://sub.example.com/path")
    end

    test "normalize handles invalid URI gracefully" do
      result = HostNormalization.normalize("::invalid::")

      assert result.nil? || result == ""
    end

    test "normalize handles whitespace around input" do
      assert_equal "example.com", HostNormalization.normalize("  example.com  ")
    end
  end
end
