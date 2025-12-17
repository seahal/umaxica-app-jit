require "test_helper"

class Authentication::StaffTest < ActiveSupport::TestCase
  class DummyClass
    include Authentication::Staff

    attr_accessor :session, :cookies, :request

    def initialize
      @session = {}
      @cookies = CookieMock.new
      @request = OpenStruct.new(host: "test.host", headers: {}, user_agent: "TestAgent")
    end

    def reset_session
      @session = {}
    end

    # Mock jwt_private_key to avoid needing actual keys
    def jwt_private_key
      @jwt_private_key ||= OpenSSL::PKey::EC.generate("prime256v1")
    end

    def jwt_public_key
      @jwt_public_key ||= jwt_private_key
    end
  end

  class CookieMock < Hash
    def encrypted
      self
    end

    def []=(key, value)
      # If value is a hash with :value key (cookie options), store just the value
      super(key, value.is_a?(Hash) && value.key?(:value) ? value[:value] : value)
    end

    def delete(key, options = {})
      super(key)
    end
  end

  setup do
    @obj = DummyClass.new
    @staff = staffs(:one)
  end

  test "module can be included" do
    assert_kind_of Authentication::Staff, @obj
  end

  test "log_in sets access token in cookie" do
    # Stub request_ip_address to avoid needing request object
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @staff)

    assert @obj.cookies[:access_staff_token]
    assert_predicate @obj, :logged_in?
    assert_equal @staff, @obj.current_staff
  end

  test "log_out clears session and current_staff" do
    # Stub request_ip_address to avoid needing request object
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @staff)
    @obj.send(:log_out)

    assert_nil @obj.session[:staff]
    assert_not @obj.logged_in?
    assert_nil @obj.current_staff
  end
end
