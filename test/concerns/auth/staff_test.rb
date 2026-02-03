# frozen_string_literal: true

require "test_helper"

class Auth::StaffTest < ActiveSupport::TestCase
  fixtures :staffs, :staff_statuses, :staff_tokens, :staff_token_kinds, :staff_token_statuses
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
    include Auth::Staff

    attr_accessor :session, :cookies, :request

    def initialize
      @session = {}
      @cookies = CookieMock.new
      @request = OpenStruct.new(host: "test.host", headers: {}, user_agent: "TestAgent", format: FormatMock.new)
    end

    def reset_session
      @session = {}
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
    @staff = staffs(:one)
  end

  test "module can be included" do
    assert_kind_of Auth::Staff, @obj
  end

  test "log_in sets access token in cookie" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @staff)

    assert @obj.cookies[::Auth::Staff::ACCESS_COOKIE_KEY]
    assert_predicate @obj, :logged_in?
    assert_equal @staff, @obj.current_staff
  end

  test "log_in sets cookie expirations" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    @obj.send(:log_in, @staff)

    access_opts = @obj.cookies.options_for(::Auth::Staff::ACCESS_COOKIE_KEY)
    refresh_opts = @obj.cookies.options_for(::Auth::Staff::REFRESH_COOKIE_KEY)

    assert_operator access_opts[:expires], :>, 10.minutes.from_now
    assert_operator access_opts[:expires], :<, 2.hours.from_now
    assert_operator refresh_opts[:expires], :>, 29.days.from_now
    assert_operator refresh_opts[:expires], :<, 31.days.from_now
  end

  test "log_out clears session and current_staff" do
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
    assert_nil @obj.cookies[::Auth::Staff::ACCESS_COOKIE_KEY]
    assert_nil @obj.cookies.encrypted[::Auth::Staff::REFRESH_COOKIE_KEY]
  end

  test "log_in derives shared cookie domain from host" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }
    @obj.request.host = "sign.org.localhost"

    @obj.send(:log_in, @staff)

    assert_equal ".org.localhost", @obj.cookies.options_for(::Auth::Staff::ACCESS_COOKIE_KEY)[:domain]
    assert_equal ".org.localhost", @obj.cookies.options_for(::Auth::Staff::REFRESH_COOKIE_KEY)[:domain]
  end

  test "log_in returns tokens hash" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    tokens = @obj.send(:log_in, @staff)

    assert_kind_of Hash, tokens
    assert tokens[:access_token]
    assert tokens[:refresh_token]
    assert_equal "Bearer", tokens[:token_type]
    assert_equal ::Auth::Base::ACCESS_TOKEN_TTL.to_i, tokens[:expires_in]
  end

  test "current_staff works with Bearer token" do
    @obj.define_singleton_method(:request_ip_address) { "127.0.0.1" }

    token_record =
      TokenRecord.connected_to(role: :writing) do
        StaffToken.create!(staff: @staff)
      end

    # Generate access token using Auth::Base::Token
    access_token = Auth::Base::Token.encode(
      @staff,
      host: @obj.request.host,
      session_public_id: token_record.public_id,
      resource_type: "staff",
    )
    @obj.request.headers["Authorization"] = "Bearer #{access_token}"

    assert_equal @staff, @obj.current_staff
  end
end
