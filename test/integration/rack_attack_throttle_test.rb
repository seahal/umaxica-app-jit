# frozen_string_literal: true

require "test_helper"

class RackAttackThrottleTest < ActionDispatch::IntegrationTest
  setup do
    @original_enabled = Rack::Attack.enabled
    @original_store = Rack::Attack.cache.store

    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    unless Rack::Attack.respond_to?(:throttle_limit_original)
      Rack::Attack.singleton_class.alias_method :throttle_limit_original, :throttle_limit
    end

    Rack::Attack.define_singleton_method(:throttle_limit) { |_base| 1 }
    Rack::Attack.reset!
  end

  teardown do
    Rack::Attack.reset!
    Rack::Attack.enabled = @original_enabled
    Rack::Attack.cache.store = @original_store

    if Rack::Attack.respond_to?(:throttle_limit_original)
      Rack::Attack.singleton_class.alias_method :throttle_limit, :throttle_limit_original
      Rack::Attack.singleton_class.undef_method :throttle_limit_original
    end
  end

  test "rack attack is disabled by default in test env" do
    original_enabled = Rack::Attack.enabled
    Rack::Attack.enabled = false

    get "/edge/v1/csrf?ri=jp", headers: { "Host" => ENV.fetch("SIGN_SERVICE_URL") }
    assert_response :success

    Rack::Attack.enabled = original_enabled
  end

  test "global throttle returns 429 with rack attack headers" do
    host = ENV.fetch("SIGN_SERVICE_URL")

    get "/edge/v1/csrf?ri=jp", headers: { "Host" => host, "Accept" => "application/json" }
    assert_response :success

    get "/edge/v1/csrf?ri=jp", headers: { "Host" => host, "Accept" => "application/json" }
    assert_response :too_many_requests

    assert_equal "rack-attack", response.headers["X-RateLimit-Layer"]
    assert_predicate response.headers["X-RateLimit-Rule"], :present?
    assert_equal "60", response.headers["Retry-After"]
  end

  test "throttle notification emits rack_attack event" do
    host = ENV.fetch("SIGN_SERVICE_URL")
    calls = []

    notifier = Object.new
    notifier.define_singleton_method(:notify) do |event, payload = {}|
      calls << [event, payload]
    end

    Rails.stub(:event, notifier) do
      get "/edge/v1/csrf?ri=jp", headers: { "Host" => host, "Accept" => "application/json" }
      get "/edge/v1/csrf?ri=jp", headers: { "Host" => host, "Accept" => "application/json" }
    end

    match = calls.find { |event, _payload| event == "rack_attack.throttled" }
    assert match, "Expected rack_attack.throttled to be emitted"

    payload = match.last
    assert_equal "global/ip", payload[:rule]
    assert_equal :throttle, payload[:match_type]
    assert_equal "/edge/v1/csrf", payload[:path]
  end
end
