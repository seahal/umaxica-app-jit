# typed: false
# frozen_string_literal: true

require "test_helper"

# ---------------------------------------------------------------------------
# Dummy controllers for testing the RateLimit concern with Rails 8.1 DSL
# ---------------------------------------------------------------------------

class RateLimitDummyController < ApplicationController
  include ::RateLimit

  rate_limit to: 1, within: 1.minute,
             by: -> { request.remote_ip },
             with: -> { handle_rate_limit_exceeded!("dummy_ip", 60) },
             store: RateLimit.store,
             name: "dummy_ip",
             only: :index

  def index
    if request.format.json?
      render json: { ok: true }
    else
      render plain: "ok"
    end
  end
end

class RateLimitExceptController < ApplicationController
  include ::RateLimit

  rate_limit to: 1, within: 1.minute,
             by: -> { request.remote_ip },
             with: -> { handle_rate_limit_exceeded!("test_rule", 60) },
             store: RateLimit.store,
             name: "test_rule",
             except: :excluded_action

  def index
    render plain: "ok"
  end

  def excluded_action
    render plain: "excluded"
  end
end

class RateLimitEmailController < ApplicationController
  include ::RateLimit

  rate_limit to: 1, within: 1.minute,
             by: -> { params[:email].to_s.strip.downcase.presence || request.remote_ip },
             with: -> { handle_rate_limit_exceeded!("email_rule", 60) },
             store: RateLimit.store,
             name: "email_rule"

  def index
    render plain: "ok"
  end
end

class RateLimitTelephoneController < ApplicationController
  include ::RateLimit

  rate_limit to: 1, within: 1.minute,
             by: -> { params[:telephone].to_s.gsub(/\D/, "").presence || request.remote_ip },
             with: -> { handle_rate_limit_exceeded!("telephone_rule", 60) },
             store: RateLimit.store,
             name: "telephone_rule"

  def index
    render plain: "ok"
  end
end

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class RateLimitConcernTest < ActionDispatch::IntegrationTest
  setup do
    RateLimit.store.clear
  end

  teardown do
    RateLimit.store.clear
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

  test "rails limiter emits a notification event" do
    payloads = []

    callback =
      lambda do |_name, _start, _finish, _id, payload|
        payloads << payload
      end

    ActiveSupport::Notifications.subscribed(callback, "rate_limit.action_controller") do
      with_dummy_route do
        get "/test_rate_limit", headers: { "Host" => "example.com", "Accept" => "application/json" }
        get "/test_rate_limit", headers: { "Host" => "example.com", "Accept" => "application/json" }
      end
    end

    assert_predicate payloads, :any?, "Expected rate_limit.action_controller to be emitted"
    payload = payloads.last

    assert_equal "dummy_ip", payload[:name]
    assert_predicate payload[:cache_key], :present?
  end

  test "rails limiter returns 429 for HTML format with plain text message" do
    with_dummy_route do
      get "/test_rate_limit"

      assert_response :success

      get "/test_rate_limit"

      assert_response :too_many_requests

      assert_equal I18n.t("errors.rate_limit.exceeded"), response.body
    end
  end

  test "rate limit with except parameter skips specified actions" do
    with_routing do |set|
      set.draw do
        get "/test_except", to: "rate_limit_except#index"
        get "/test_except_excluded", to: "rate_limit_except#excluded_action"
      end

      get "/test_except", headers: { "Host" => "example.com" }

      assert_response :success

      get "/test_except", headers: { "Host" => "example.com" }

      assert_response :too_many_requests

      # Excluded action should not be rate limited
      get "/test_except_excluded", headers: { "Host" => "example.com" }

      assert_response :success

      get "/test_except_excluded", headers: { "Host" => "example.com" }

      assert_response :success
    end
  end

  test "rate limit with email scope uses email parameter as discriminator" do
    with_routing do |set|
      set.draw do
        get "/test_email", to: "rate_limit_email#index"
      end

      get "/test_email", params: { email: "test@example.com" }, headers: { "Host" => "example.com" }

      assert_response :success

      get "/test_email", params: { email: "test@example.com" }, headers: { "Host" => "example.com" }

      assert_response :too_many_requests
    end
  end

  test "rate limit with telephone scope uses telephone parameter as discriminator" do
    with_routing do |set|
      set.draw do
        get "/test_telephone", to: "rate_limit_telephone#index"
      end

      get "/test_telephone", params: { telephone: "+1-555-123-4567" }, headers: { "Host" => "example.com" }

      assert_response :success

      get "/test_telephone", params: { telephone: "+1-555-123-4567" }, headers: { "Host" => "example.com" }

      assert_response :too_many_requests

      # Different telephone should not be rate limited
      get "/test_telephone", params: { telephone: "+1-555-999-8888" }, headers: { "Host" => "example.com" }

      assert_response :success
    end
  end

  test "rate_limit_store class method returns the shared store" do
    assert_equal RateLimit.store, RateLimitDummyController.rate_limit_store
  end

  private

  def with_dummy_route
    with_routing do |set|
      set.draw do
        get("/test_rate_limit", to: "rate_limit_dummy#index")
      end

      yield
    end
  end
end
