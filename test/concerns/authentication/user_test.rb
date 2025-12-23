require "test_helper"

class Authentication::UserTest < ActiveSupport::TestCase
  class FormatMock
    attr_accessor :format_type

    def initialize(format_type = :html)
      @format_type = format_type
    end

    def json?
      @format_type == :json
    end
  end

  class DummyClass
    include Authentication::User

    attr_accessor :session, :cookies, :request

    def initialize
      @session = {}
      @cookies = CookieMock.new
      format = FormatMock.new
      @request = OpenStruct.new(host: "test.host", headers: {}, user_agent: "TestAgent", format: format)
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
    @user = users(:one)
  end

  test "module can be included" do
    assert_kind_of Authentication::User, @obj
  end

  test "log_in sets access token in cookie" do
    # Stub request_ip_address to avoid needing request object
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @user)

    assert @obj.cookies[Authentication::User::ACCESS_COOKIE_KEY]
    assert_predicate @obj, :logged_in?
    assert_equal @user, @obj.current_user
  end

  test "log_in sets cookie expirations" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @user)

    access_opts = @obj.cookies.options_for(Authentication::User::ACCESS_COOKIE_KEY)
    refresh_opts = @obj.cookies.options_for(Authentication::User::REFRESH_COOKIE_KEY)

    assert_operator access_opts[:expires], :>, 10.minutes.from_now
    assert_operator access_opts[:expires], :<, 20.minutes.from_now
    assert_operator refresh_opts[:expires], :>, 11.months.from_now
    assert_operator refresh_opts[:expires], :<, 13.months.from_now
  end

  test "log_out clears session and current_user" do
    # Stub request_ip_address to avoid needing request object
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @user)
    @obj.send(:log_out)

    assert_not_predicate @obj, :logged_in?
    assert_nil @obj.current_user
  end

  test "log_out removes refresh token and cookies" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @user)
    assert_difference("UserToken.count", -1) { @obj.send(:log_out) }

    assert_nil @obj.cookies[Authentication::User::ACCESS_COOKIE_KEY]
    assert_nil @obj.cookies.encrypted[Authentication::User::REFRESH_COOKIE_KEY]
  end

  test "log_in derives shared cookie domain from host" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }
    @obj.request.host = "sign.app.localhost"

    @obj.send(:log_in, @user)

    assert_equal ".app.localhost", @obj.cookies.options_for(Authentication::User::ACCESS_COOKIE_KEY)[:domain]
    assert_equal ".app.localhost", @obj.cookies.options_for(Authentication::User::REFRESH_COOKIE_KEY)[:domain]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "log_in returns tokens hash" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    tokens = @obj.send(:log_in, @user)

    assert_kind_of Hash, tokens
    assert tokens[:access_token]
    assert tokens[:refresh_token]
    assert_equal "Bearer", tokens[:token_type]
    assert_equal Authentication::Base::ACCESS_TOKEN_EXPIRY.to_i, tokens[:expires_in]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "log_in skips cookies for JSON format" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }
    @obj.request.format.format_type = :json

    @obj.send(:log_in, @user)

    assert_nil @obj.cookies[Authentication::User::ACCESS_COOKIE_KEY]
    assert_nil @obj.cookies.encrypted[Authentication::User::REFRESH_COOKIE_KEY]
  end

  test "extract_access_token from Authorization header" do
    token = "sample_jwt_token"
    @obj.request.headers["Authorization"] = "Bearer #{token}"

    extracted = @obj.send(:extract_access_token, Authentication::User::ACCESS_COOKIE_KEY)

    assert_equal token, extracted
  end

  test "extract_access_token from Cookie when no Authorization header" do
    token = "cookie_jwt_token"
    @obj.cookies[Authentication::User::ACCESS_COOKIE_KEY] = token

    extracted = @obj.send(:extract_access_token, Authentication::User::ACCESS_COOKIE_KEY)

    assert_equal token, extracted
  end

  test "extract_access_token prioritizes Authorization header over Cookie" do
    header_token = "header_jwt_token"
    cookie_token = "cookie_jwt_token"
    @obj.request.headers["Authorization"] = "Bearer #{header_token}"
    @obj.cookies[Authentication::User::ACCESS_COOKIE_KEY] = cookie_token

    extracted = @obj.send(:extract_access_token, Authentication::User::ACCESS_COOKIE_KEY)

    assert_equal header_token, extracted
  end

  test "current_user works with Bearer token" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    # Generate access token
    access_token = @obj.send(:generate_access_token, @user)
    @obj.request.headers["Authorization"] = "Bearer #{access_token}"

    assert_equal @user, @obj.current_user
  end
end
