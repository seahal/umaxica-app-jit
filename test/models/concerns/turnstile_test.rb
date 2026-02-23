# typed: false
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
    Jit::Security::TurnstileVerifier.test_mode = false
    Jit::Security::TurnstileVerifier.test_response = nil
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

    assert_equal({ "success" => false, "error" => "missing cf-turnstile-response" }, result)
  end

  test "verify_turnstile returns missing secret error" do
    Jit::Security::TurnstileConfig.stub(:default_secret_key, nil) do
      result = DummyTurnstile.verify_turnstile(turnstile_response: "token", remote_ip: "127.0.0.1")

      assert_equal({ "success" => false, "error" => "missing turnstile secret" }, result)
    end
  end

  test "verify_turnstile returns error result on exception" do
    Jit::Security::TurnstileConfig.stub(:default_secret_key, "dummy") do
      Net::HTTP.stub(:post_form, ->(_uri, _params) { raise StandardError, "Network error" }) do
        result = DummyTurnstile.verify_turnstile(turnstile_response: "token", remote_ip: "127.0.0.1")
        assert_not result["success"]
        assert_equal "Network error", result["error"]
      end
    end
  end

  test "verify_turnstile returns parsed response on success" do
    response = Struct.new(:body).new('{"success":true}')

    Jit::Security::TurnstileConfig.stub(:default_secret_key, "secret") do
      Net::HTTP.stub(:post_form, response) do
        result = DummyTurnstile.verify_turnstile(turnstile_response: "token", remote_ip: "127.0.0.1")

        assert_equal({ "success" => true }, result)
      end
    end
  end

  test "turnstile_error_message uses default when none provided" do
    model = DummyTurnstile.new
    assert_equal I18n.t("turnstile_error"), model.turnstile_error_message
  end
end
