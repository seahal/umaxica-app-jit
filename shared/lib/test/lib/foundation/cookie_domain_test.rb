# typed: false
# frozen_string_literal: true

require "test_helper"

class CookieDomainTest < ActiveSupport::TestCase
  def stub_creds(_key, value)
    creds_mock = Object.new
    creds_mock.define_singleton_method(:option) { |_key| value }
    Rails.stub(:app, OpenStruct.new(creds: creds_mock)) do
      yield
    end
  end

  test "for returns nil when env variable is blank and request host is localhost" do
    stub_creds(:COOKIE_DOMAIN_APP, nil) do
      result = Base::CookieDomain.for(surface: :app, request_host: "localhost")

      assert_nil result
    end
  end

  test "for returns nil when com env variable is blank and request host is localhost" do
    stub_creds(:COOKIE_DOMAIN_COM, nil) do
      result = Base::CookieDomain.for(surface: :com, request_host: "localhost")

      assert_nil result
    end
  end

  test "for returns nil when env variable is set to HOST_ONLY" do
    stub_creds(:COOKIE_DOMAIN_APP, "HOST_ONLY") do
      result = Base::CookieDomain.for(surface: :app, request_host: "app.example.com")

      assert_nil result
    end
  end

  test "for derives domain from request host" do
    stub_creds(:COOKIE_DOMAIN_APP, nil) do
      result = Base::CookieDomain.for(surface: :app, request_host: "app.example.com")

      assert_equal ".example.com", result
    end
  end

  test "for derives domain from request host with subdomain" do
    stub_creds(:COOKIE_DOMAIN_APP, nil) do
      result = Base::CookieDomain.for(surface: :app, request_host: "ww.app.example.com")

      assert_equal ".example.com", result
    end
  end

  test "for derives domain from request host for com surface" do
    stub_creds(:COOKIE_DOMAIN_COM, nil) do
      result = Base::CookieDomain.for(surface: :com, request_host: "main.com.example.com")

      assert_equal ".example.com", result
    end
  end

  test "for handles IP address" do
    stub_creds(:COOKIE_DOMAIN_APP, nil) do
      result = Base::CookieDomain.for(surface: :app, request_host: "192.168.1.1")

      assert_equal ".1.1", result
    end
  end

  test "for uses configured env variable" do
    stub_creds(:COOKIE_DOMAIN_ORG, nil) do
      result = Base::CookieDomain.for(surface: :org, request_host: "localhost")

      assert_nil result
    end
  end

  test "for uses configured env variable for com surface" do
    stub_creds(:COOKIE_DOMAIN_COM, ".com.example.com") do
      result = Base::CookieDomain.for(surface: :com, request_host: "main.com.example.com")

      assert_equal ".com.example.com", result
    end
  end

  test "normalize_configured returns nil for blank value" do
    assert_nil Base::CookieDomain.send(:normalize_configured, "")
    assert_nil Base::CookieDomain.send(:normalize_configured, nil)
  end

  test "normalize_configured returns nil for HOST_ONLY" do
    assert_nil Base::CookieDomain.send(:normalize_configured, "HOST_ONLY")
  end

  test "normalize_configured adds dot prefix" do
    result = Base::CookieDomain.send(:normalize_configured, "example.com")

    assert_equal ".example.com", result
  end

  test "normalize_configured preserves dot prefix" do
    result = Base::CookieDomain.send(:normalize_configured, ".example.com")

    assert_equal ".example.com", result
  end

  test "normalize_host lowercases and removes trailing dot" do
    assert_equal "example.com", Base::CookieDomain.send(:normalize_host, "EXAMPLE.COM")
    assert_equal "example.com", Base::CookieDomain.send(:normalize_host, "example.com.")
  end

  test "normalize_host removes port" do
    assert_equal "example.com", Base::CookieDomain.send(:normalize_host, "example.com:8080")
  end

  test "normalize_host extracts host from a URL string" do
    assert_equal "app.example.com", Base::CookieDomain.send(:normalize_host, "https://APP.EXAMPLE.COM:3000/path")
  end

  test "localhost_host? returns true for localhost" do
    assert Base::CookieDomain.send(:localhost_host?, "localhost")
  end

  test "localhost_host? returns true for subdomain of localhost" do
    assert Base::CookieDomain.send(:localhost_host?, "app.localhost")
  end

  test "localhost_host? returns false for other hosts" do
    assert_not Base::CookieDomain.send(:localhost_host?, "example.com")
  end

  test "best_effort_acme extracts acme domain" do
    assert_equal "example.com", Base::CookieDomain.send(:best_effort_acme, "app.example.com")
    assert_equal "example.com", Base::CookieDomain.send(:best_effort_acme, "ww.example.com")
  end

  test "best_effort_acme returns nil for single part" do
    assert_nil Base::CookieDomain.send(:best_effort_acme, "localhost")
  end
end
