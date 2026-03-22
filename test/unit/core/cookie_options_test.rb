# typed: false
# frozen_string_literal: true

require "test_helper"

class CoreCookieOptionsTest < ActiveSupport::TestCase
  class MockRequest
    attr_reader :host, :ssl

    def initialize(host, ssl: false)
      @host = host
      @ssl = ssl
    end

    def ssl?
      @ssl
    end
  end

  test "for returns httponly and secure options" do
    request = MockRequest.new("www.example.com")
    surface = :app

    options = Core::CookieOptions.for(surface: surface, request: request, secure: true)

    assert options[:httponly]
    assert options[:secure]
  end

  test "for includes same_site when provided" do
    request = MockRequest.new("www.example.com")

    options = Core::CookieOptions.for(surface: :app, request: request, same_site: :lax)

    assert_equal :lax, options[:same_site]
  end

  test "for includes expires when provided" do
    request = MockRequest.new("www.example.com")
    expires = 1.year.from_now

    options = Core::CookieOptions.for(surface: :app, request: request, expires: expires)

    assert_equal expires, options[:expires]
  end

  test "for includes path when provided" do
    request = MockRequest.new("www.example.com")

    options = Core::CookieOptions.for(surface: :app, request: request, path: "/accounts")

    assert_equal "/accounts", options[:path]
  end

  test "for includes domain when surface has domain" do
    request = MockRequest.new("www.example.com")

    options = Core::CookieOptions.for(surface: :app, request: request)

    assert_predicate options[:domain], :present? if options[:domain]
  end
end
