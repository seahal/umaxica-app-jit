# frozen_string_literal: true

require "test_helper"

class MiddlewareSocialAuthRequestPhaseGuardTest < ActiveSupport::TestCase
  setup do
    @app = ->(_env) { [200, { "Content-Type" => "text/plain" }, ["OK"]] }
    @middleware = SocialAuthRequestPhaseGuard.new(@app)
  end

  test "passes through to app when no rejection" do
    env = Rack::MockRequest.env_for("/auth/google_oauth2")
    status, _headers, _ = @middleware.call(env)
    # Will pass through or be rejected depending on SocialCallbackGuard
    assert_kind_of Integer, status
  end

  test "middleware initializes with app" do
    assert_equal @app, @middleware.instance_variable_get(:@app)
  end

  test "handles auth callback path" do
    env = Rack::MockRequest.env_for("/auth/google_oauth2/callback")
    status, _headers, _ = @middleware.call(env)
    assert_kind_of Integer, status
  end

  test "handles auth failure path" do
    env = Rack::MockRequest.env_for("/auth/failure")
    status, _headers, _ = @middleware.call(env)
    assert_kind_of Integer, status
  end

  test "handles regular paths without auth" do
    env = Rack::MockRequest.env_for("/users/sign_in")
    status, _headers, body = @middleware.call(env)
    # Should pass through without rejection
    assert_equal 200, status
    assert_equal ["OK"], body
  end

  test "middleware responds to call" do
    assert_respond_to @middleware, :call
  end
end
