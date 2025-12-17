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
    attr_reader :options

    def initialize
      super
      @options = {}
    end

    def encrypted
      self
    end

    def []=(key, value)
      if value.is_a?(Hash) && value.key?(:value)
        opts = value.dup
        actual_value = opts.delete(:value)
        super(key, actual_value)
        @options[key] = opts
      else
        super(key, value)
      end
    end

    def delete(key, options = {})
      super(key)
    end

    def options_for(key)
      @options[key]
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

    assert_not_predicate @obj, :logged_in?
    assert_nil @obj.current_staff
  end

  test "log_out removes refresh token and cookies" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }
    @obj.send(:log_in, @staff)

    assert_difference("StaffToken.count", -1) { @obj.send(:log_out) }
    assert_nil @obj.cookies[:access_staff_token]
    assert_nil @obj.cookies.encrypted[:refresh_staff_token]
  end

  test "log_in derives shared cookie domain from host" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }
    @obj.request.host = "sign.org.localhost"

    @obj.send(:log_in, @staff)

    assert_equal ".org.localhost", @obj.cookies.options_for(:access_staff_token)[:domain]
    assert_equal ".org.localhost", @obj.cookies.options_for(:refresh_staff_token)[:domain]
  end
end
