# typed: false
# frozen_string_literal: true

require "test_helper"

module Core
  class CookieDomainTest < ActiveSupport::TestCase
    test "normalizes app.localhost env to .app.localhost" do
      with_env("COOKIE_DOMAIN_APP" => "app.localhost") do
        assert_equal ".app.localhost", Core::CookieDomain.for(surface: :app, request_host: "app.localhost")
      end
    end

    test "normalizes example.com env to .example.com" do
      with_env("COOKIE_DOMAIN_APP" => "example.com") do
        assert_equal ".example.com", Core::CookieDomain.for(surface: :app, request_host: "app.localhost")
      end
    end

    test "keeps dotted env as is" do
      with_env("COOKIE_DOMAIN_APP" => ".example.com") do
        assert_equal ".example.com", Core::CookieDomain.for(surface: :app, request_host: "app.localhost")
      end
    end

    test "returns host-only when env is HOST_ONLY" do
      with_env("COOKIE_DOMAIN_APP" => "HOST_ONLY") do
        assert_nil Core::CookieDomain.for(surface: :app, request_host: "app.localhost")
      end
    end

    test "derives .app.localhost when env blank and host is app.localhost" do
      with_env("COOKIE_DOMAIN_APP" => nil) do
        assert_equal ".app.localhost", Core::CookieDomain.for(surface: :app, request_host: "app.localhost")
      end
    end

    test "derives .app.localhost for nested localhost hosts" do
      with_env("COOKIE_DOMAIN_APP" => nil) do
        assert_equal ".app.localhost", Core::CookieDomain.for(surface: :app, request_host: "sign.app.localhost")
      end
    end

    test "derives .example.com when env blank and host is app.example.com" do
      with_env("COOKIE_DOMAIN_APP" => nil) do
        assert_equal ".example.com", Core::CookieDomain.for(surface: :app, request_host: "app.example.com")
      end
    end

    test "returns nil when host is localhost" do
      with_env("COOKIE_DOMAIN_APP" => nil) do
        assert_nil Core::CookieDomain.for(surface: :app, request_host: "localhost")
      end
    end

    private

    def with_env(vars)
      original = {}
      vars.each_key { |key| original[key] = ENV[key] }

      vars.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end

      yield
    ensure
      original.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
    end
  end
end
