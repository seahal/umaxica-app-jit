# typed: false
# frozen_string_literal: true

require "test_helper"

class AuthDeviceValidationTest < ActiveSupport::TestCase
  class DeviceHarness
    include Auth::Base

    attr_accessor :request_obj, :cookies_hash, :refresh_device_reason

    def initialize
      @request_obj = MockRequest.new
      @cookies_hash = MockCookies.new
      @refresh_device_reason = nil
    end

    def request
      @request_obj
    end

    def cookies
      @cookies_hash
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

  class MockCookies
    def initialize
      @store = {}
    end

    def encrypted
      @store
    end

    delegate :[]=, to: :@store
  end

  class MockRequest
    attr_accessor :headers_hash, :host, :remote_ip

    def initialize
      @headers_hash = {}
      @host = "example.com"
      @remote_ip = "127.0.0.1"
    end

    def headers
      @headers_hash
    end

    def format
      MockFormat.new
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
    @harness = DeviceHarness.new
  end

  test "refresh_device_allowed? returns true when device ID matches via header" do
    token_record = UserToken.new(device_id: "device-123")
    @harness.request_obj.headers_hash[Auth::IoKeys::Headers::DEVICE_ID] = "device-123"

    assert @harness.send(:refresh_device_allowed?, token_record)
  end

  test "refresh_device_allowed? returns false when device ID mismatch" do
    token_record = UserToken.new(device_id: "device-123")
    @harness.request_obj.headers_hash[Auth::IoKeys::Headers::DEVICE_ID] = "device-456"

    assert_not @harness.send(:refresh_device_allowed?, token_record)
    assert_equal "mismatch", @harness.instance_variable_get(:@refresh_device_reason)
  end

  test "refresh_device_allowed? returns false when device ID missing" do
    token_record = UserToken.new(device_id: "device-123")
    @harness.request_obj.headers_hash[Auth::IoKeys::Headers::STRICT_DEVICE_CHECK] = "true"

    assert_not @harness.send(:refresh_device_allowed?, token_record)
    assert_equal "missing", @harness.instance_variable_get(:@refresh_device_reason)
  end

  test "refresh_device_allowed? returns false when token has no device ID and header provided" do
    token_record = UserToken.new(device_id: nil)
    @harness.request_obj.headers_hash[Auth::IoKeys::Headers::DEVICE_ID] = "device-123"

    result = @harness.send(:refresh_device_allowed?, token_record)

    assert_not result
  end

  test "clear_refresh_failure! resets all failure variables" do
    @harness.instance_variable_set(:@refresh_failure_status, :unauthorized)
    @harness.instance_variable_set(:@refresh_failure_code, "invalid_token")
    @harness.instance_variable_set(:@refresh_device_reason, "mismatch")

    @harness.send(:clear_refresh_failure!)

    assert_nil @harness.instance_variable_get(:@refresh_failure_status)
    assert_nil @harness.instance_variable_get(:@refresh_failure_code)
    assert_nil @harness.instance_variable_get(:@refresh_device_reason)
  end
end
