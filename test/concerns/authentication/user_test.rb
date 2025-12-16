require "test_helper"

class Authentication::UserTest < ActiveSupport::TestCase
  class DummyClass
    include Authentication::User

    attr_accessor :session, :cookies, :request

    def initialize
      @session = {}
      @cookies = CookieMock.new
      @request = OpenStruct.new(host: "test.host", headers: {})
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
    @user = users(:one)
  end

  test "module can be included" do
    assert_kind_of Authentication::User, @obj
  end

  test "log_in sets user_id in session" do
    # Stub request_ip_address to avoid needing request object
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @user)

    assert_equal @user.id, @obj.session[:user_id]
    assert_predicate @obj, :logged_in?
    assert_equal @user, @obj.current_user
  end

  test "log_out clears session and current_user" do
    # Stub request_ip_address to avoid needing request object
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @user)
    @obj.send(:log_out)

    assert_nil @obj.session[:user_id]
    assert_not @obj.logged_in?
    assert_nil @obj.current_user
  end

  test "log_in records login audit" do
    # Stub request_ip_address to return a test IP
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    assert_difference "UserIdentityAudit.count", 1 do
      @obj.send(:log_in, @user)
    end
  end

  test "log_in audit record has correct attributes" do
    # Stub request_ip_address to return a test IP
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @user)
    audit = UserIdentityAudit.last

    assert_equal [ @user, "LOGGED_IN", "127.0.0.1", @user ],
                 [ audit.user, audit.event_id, audit.ip_address, audit.actor ]
  end

  test "log_out records logout audit" do
    # Stub request_ip_address to return a test IP
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    # Login first (creates one audit record)
    @obj.send(:log_in, @user)

    assert_difference "UserIdentityAudit.count", 1 do
      @obj.send(:log_out)
    end
  end

  test "log_out audit record has correct attributes" do
    # Stub request_ip_address to return a test IP
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    # Login first (creates one audit record)
    @obj.send(:log_in, @user)
    # Logout
    @obj.send(:log_out)

    # Get the logout audit (the last one)
    logout_audit = UserIdentityAudit.where(event_id: "LOGGED_OUT").last

    assert_not_nil logout_audit
    assert_equal [ @user, "LOGGED_OUT", "127.0.0.1", @user ],
                 [ logout_audit.user, logout_audit.event_id, logout_audit.ip_address, logout_audit.actor ]
  end
end
