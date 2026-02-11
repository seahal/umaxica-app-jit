# frozen_string_literal: true

require "test_helper"

class Auth::UserTest < ActiveSupport::TestCase
  fixtures :user_statuses

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
    include Auth::User

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

    def controller_path
      "auth/users"
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

    def delete(key, _options = {})
      super(key)
    end

    def options_for(key)
      @options[key]
    end
  end

  setup do
    @obj = DummyClass.new
    @user = User.create!(status_id: UserStatus::NEYO, public_id: SecureRandom.alphanumeric(21))
    UserToken.where(user_id: @user.id).delete_all
  end

  test "module can be included" do
    assert_kind_of Auth::User, @obj
  end

  test "log_in sets access token in cookie" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @user)

    assert @obj.cookies[::Auth::User::ACCESS_COOKIE_KEY]
    assert_predicate @obj, :logged_in?
    assert_equal @user, @obj.current_user
  end

  test "log_in sets cookie expirations" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @user)

    access_opts = @obj.cookies.options_for(::Auth::User::ACCESS_COOKIE_KEY)
    refresh_opts = @obj.cookies.options_for(::Auth::User::REFRESH_COOKIE_KEY)

    assert_operator access_opts[:expires], :>, 10.minutes.from_now
    assert_operator access_opts[:expires], :<, 2.hours.from_now
    assert_operator refresh_opts[:expires], :>, 29.days.from_now
    assert_operator refresh_opts[:expires], :<, 31.days.from_now
  end

  test "log_out clears session and current_user" do
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

    assert_nil @obj.cookies[::Auth::User::ACCESS_COOKIE_KEY]
    assert_nil @obj.cookies.encrypted[::Auth::User::REFRESH_COOKIE_KEY]
  end

  test "log_in derives shared cookie domain from host" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }
    @obj.request.host = "sign.app.localhost"

    @obj.send(:log_in, @user)

    assert_equal ".app.localhost", @obj.cookies.options_for(::Auth::User::ACCESS_COOKIE_KEY)[:domain]
    assert_equal ".app.localhost", @obj.cookies.options_for(::Auth::User::REFRESH_COOKIE_KEY)[:domain]
  end

  test "log_in returns tokens hash" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    tokens = @obj.send(:log_in, @user)

    assert_kind_of Hash, tokens
    assert tokens[:access_token]
    assert tokens[:refresh_token]
    assert_equal "Bearer", tokens[:token_type]
    assert_equal ::Auth::Base::ACCESS_TOKEN_TTL.to_i, tokens[:expires_in]
  end

  test "log_in skips cookies for JSON format" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }
    @obj.request.format.format_type = :json

    @obj.send(:log_in, @user)

    assert @obj.cookies[::Auth::User::ACCESS_COOKIE_KEY]
    assert @obj.cookies.encrypted[::Auth::User::REFRESH_COOKIE_KEY]
  end

  test "extract_access_token from Authorization header" do
    token = "sample_jwt_token"
    @obj.request.headers["Authorization"] = "Bearer #{token}"

    extracted = @obj.send(:extract_access_token, ::Auth::User::ACCESS_COOKIE_KEY)

    assert_equal token, extracted
  end

  test "extract_access_token from Cookie when no Authorization header" do
    token = "cookie_jwt_token"
    @obj.cookies[::Auth::User::ACCESS_COOKIE_KEY] = token

    extracted = @obj.send(:extract_access_token, ::Auth::User::ACCESS_COOKIE_KEY)

    assert_equal token, extracted
  end

  test "extract_access_token prioritizes Authorization header over Cookie" do
    header_token = "header_jwt_token"
    cookie_token = "cookie_jwt_token"
    @obj.request.headers["Authorization"] = "Bearer #{header_token}"
    @obj.cookies[::Auth::User::ACCESS_COOKIE_KEY] = cookie_token

    extracted = @obj.send(:extract_access_token, ::Auth::User::ACCESS_COOKIE_KEY)

    assert_equal header_token, extracted
  end

  test "current_user works with Bearer token" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    token_record =
      TokenRecord.connected_to(role: :writing) do
        UserToken.create!(user: @user)
      end

    # Generate access token using Auth::Base::Token
    access_token = Auth::Base::Token.encode(
      @user,
      host: @obj.request.host,
      session_public_id: token_record.public_id,
      resource_type: "user",
    )
    @obj.request.headers["Authorization"] = "Bearer #{access_token}"

    assert_equal @user, @obj.current_user
  end

  test "log_in hard rejects when active and restricted sessions already exist" do
    2.times do
      token = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
      token.rotate_refresh_token!
    end
    restricted = UserToken.create!(user: @user, status: UserToken::STATUS_RESTRICTED)
    restricted.rotate_refresh_token!(expires_at: 15.minutes.from_now)
    before_ids = UserToken.where(user_id: @user.id).order(:id).pluck(:id, :status, :revoked_at)

    result = @obj.send(:log_in, @user, require_totp_check: false)

    assert_equal :session_limit_hard_reject, result[:status]
    assert_equal :conflict, result[:http_status]
    assert_equal Auth::Base::SESSION_LIMIT_HARD_REJECT_MESSAGE, result[:message]
    assert_equal before_ids, UserToken.where(user_id: @user.id).order(:id).pluck(:id, :status, :revoked_at)
  end

  test "log_in issues restricted session with 15 minute ttl when active sessions reach limit" do
    2.times do
      token = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
      token.rotate_refresh_token!
    end

    freeze_time do
      result = @obj.send(:log_in, @user, require_totp_check: false)
      assert_equal :success, result[:status]
      assert result[:restricted]

      restricted = UserToken.where(user_id: @user.id, status: UserToken::STATUS_RESTRICTED).order(:created_at).last
      assert_not_nil restricted
      assert_in_delta 15.minutes.from_now.to_i, restricted.refresh_expires_at.to_i, 1
    end
  end
end
