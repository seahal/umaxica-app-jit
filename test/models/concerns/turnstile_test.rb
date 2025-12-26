# frozen_string_literal: true

require "test_helper"

class TurnstileTest < ActiveSupport::TestCase
  class DummyTurnstile
    include ActiveModel::Model
    include Turnstile
  end

  setup do
    @original_test_response = Turnstile.test_response
    Turnstile.test_response = nil
  end

  teardown do
    Turnstile.test_response = @original_test_response
  end

  test "require_turnstile marks model as required" do
    model = DummyTurnstile.new

    result = model.require_turnstile(response: "token", remote_ip: "127.0.0.1")

    assert_equal model, result
    assert_predicate model, :turnstile_required?
  end

  test "require_turnstile stores response data" do
    model = DummyTurnstile.new

    model.require_turnstile(response: "token", remote_ip: "127.0.0.1")

    assert_equal "token", model.turnstile_response
    assert_equal "127.0.0.1", model.turnstile_remote_ip
  end

  test "turnstile_error_message uses custom message" do
    model = DummyTurnstile.new

    model.require_turnstile(response: "token", remote_ip: "127.0.0.1", error_message: "custom")

    assert_equal "custom", model.turnstile_error_message
  end

  test "turnstile_valid? returns true when not required" do
    model = DummyTurnstile.new

    assert_predicate model, :turnstile_valid?
  end

  test "turnstile_valid? uses verification result when required" do
    Turnstile.test_response = { "success" => true }
    model = DummyTurnstile.new.require_turnstile(response: "token", remote_ip: "127.0.0.1")

    assert_predicate model, :turnstile_valid?
  end

  test "verify_turnstile returns missing response error" do
    result = DummyTurnstile.verify_turnstile(turnstile_response: nil, remote_ip: "127.0.0.1")

    assert_equal DummyTurnstile.missing_response_error, result
  end

  test "verify_turnstile returns missing secret error" do
    old_env = ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"]
    ENV.delete("CLOUDFLARE_TURNSTILE_SECRET_KEY")

    Rails.application.credentials.stub(:dig, nil) do
      result = DummyTurnstile.verify_turnstile(turnstile_response: "token", remote_ip: "127.0.0.1")

      assert_equal DummyTurnstile.missing_secret_error, result
    end
  ensure
    ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"] = old_env
  end
end
