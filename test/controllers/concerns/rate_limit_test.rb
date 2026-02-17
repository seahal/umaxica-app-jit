# frozen_string_literal: true

require "test_helper"

class RateLimitDummyController < ApplicationController
  include ::RateLimit

  rate_limit_rule :dummy_ip, scope: :ip, limit: 1, period: 60, only: :index

  def index
    if request.format.json?
      render json: { ok: true }
    else
      render plain: "ok"
    end
  end
end

class RateLimitConcernTest < ActionDispatch::IntegrationTest
  setup do
    RailsRateLimit.store.clear if RailsRateLimit.store.respond_to?(:clear)
  end

  teardown do
    RailsRateLimit.store.clear if RailsRateLimit.store.respond_to?(:clear)
  end

  test "rails rate limiter returns 429 with layer headers and i18n message" do
    with_dummy_route do
      get "/test_rate_limit", headers: { "Host" => "example.com", "Accept" => "application/json" }
      assert_response :success

      get "/test_rate_limit", headers: { "Host" => "example.com", "Accept" => "application/json" }
      assert_response :too_many_requests

      assert_equal "rails", response.headers["X-RateLimit-Layer"]
      assert_equal "dummy_ip", response.headers["X-RateLimit-Rule"]
      assert_predicate response.headers["Retry-After"], :present?

      body = response.parsed_body
      assert_equal "rate_limited", body["error"]
      assert_equal "dummy_ip", body["rule"]
      assert_equal I18n.t("errors.rate_limit.exceeded"), body["message"]
    end
  end

  test "rails limiter emits a distinct notifications event" do
    payloads = []

    callback =
      lambda do |_name, _start, _finish, _id, payload|
        payloads << payload
      end

    ActiveSupport::Notifications.subscribed(callback, "rails_rate_limit.throttled") do
      with_dummy_route do
        get "/test_rate_limit", headers: { "Host" => "example.com", "Accept" => "application/json" }
        get "/test_rate_limit", headers: { "Host" => "example.com", "Accept" => "application/json" }
      end
    end

    assert_predicate payloads, :any?, "Expected rails_rate_limit.throttled to be emitted"
    payload = payloads.last
    assert_equal "dummy_ip", payload[:rule]
    assert_equal "example.com", payload[:tenant]
    assert_equal "ip", payload[:scope]
    assert_equal "/test_rate_limit", payload[:path]
  end

  test "rails limiter uses dedicated namespace and does not collide with rack attack namespace" do
    with_dummy_route do
      get "/test_rate_limit", headers: { "Host" => "example.com", "Accept" => "application/json" }
    end

    assert_equal "rails_rate_limit", RailsRateLimit.store.options[:namespace]

    keys = RailsRateLimit.store.instance_variable_get(:@data).keys
    assert keys.any? { |key| key.start_with?("rails_rate_limit:dummy_ip:") }
    assert keys.none? { |key| key.start_with?("rack_attack:") }
  end

  private

  def with_dummy_route
    with_routing do |set|
      set.draw do
        get "/test_rate_limit", to: "rate_limit_dummy#index"
      end

      yield
    end
  end
end
