# typed: false
# frozen_string_literal: true

require "test_helper"

class AuthCookieHelpersTest < ActiveSupport::TestCase
  class CookieHarness
    include Authentication::Base

    attr_accessor :cookies, :request_obj

    def initialize
      @cookies = {}
      @request_obj = MockRequest.new
    end

    def request
      @request_obj
    end

    def resource_type
      "user"
    end

    def resource_class
      User
    end

    def token_class
      UserToken
    end

    def audit_class
      UserActivity
    end

    def resource_foreign_key
      :user_id
    end

    def sign_in_url_with_return(_return_to)
      "/sign/in"
    end

    def am_i_user?
      false
    end

    def am_i_staff?
      false
    end

    def am_i_owner?
      false
    end
  end

  class MockRequest
    attr_accessor :host, :remote_ip, :user_agent, :request_id

    def initialize
      @host = "example.com"
      @remote_ip = "127.0.0.1"
      @user_agent = "TestAgent"
      @request_id = "test-123"
    end

    def format
      MockFormat.new
    end

    def headers
      {}
    end

    def ssl?
      false
    end
  end

  class MockFormat
    def json?
      false
    end

    def html?
      true
    end
  end

  setup do
    @harness = CookieHarness.new
  end

  test "device_cookie_key returns correct key name" do
    key = @harness.send(:device_cookie_key)

    assert_equal "auth_device_id", key
  end

  test "ACCESS_COOKIE_KEY constant is defined" do
    assert_equal "auth_access", Authentication::Base::ACCESS_COOKIE_KEY
  end

  test "REFRESH_COOKIE_KEY constant is defined" do
    assert_equal "auth_refresh", Authentication::Base::REFRESH_COOKIE_KEY
  end

  test "DEVICE_COOKIE_KEY constant is defined" do
    assert_equal "auth_device_id", Authentication::Base::DEVICE_COOKIE_KEY
  end

  test "cookie_options keeps auth cookies host-only" do
    options = @harness.send(:cookie_options)

    assert_nil options[:domain]
    assert_equal "/", options[:path]
    assert_equal :lax, options[:same_site]
    assert options[:httponly]
  end

  test "cookie_deletion_options keeps auth cookies host-only" do
    options = @harness.send(:cookie_deletion_options)

    assert_nil options[:domain]
    assert_equal "/", options[:path]
    assert_not options.key?(:same_site)
    assert_not options.key?(:httponly)
    assert_not options.key?(:secure)
  end

  test "ACCESS_TOKEN_TTL defaults to 1 hour" do
    assert_equal 1.hour.to_i, Authentication::Base::ACCESS_TOKEN_TTL.to_i
  end

  test "REFRESH_TOKEN_TTL is 30 days" do
    assert_equal 30.days, Authentication::Base::REFRESH_TOKEN_TTL
  end

  test "RESTRICTED_SESSION_TTL is 15 minutes" do
    assert_equal 15.minutes, Authentication::Base::RESTRICTED_SESSION_TTL
  end
end
