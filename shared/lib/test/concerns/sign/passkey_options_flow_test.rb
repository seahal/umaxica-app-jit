# typed: false
# frozen_string_literal: true

require "test_helper"

class PasskeyOptionsFlowTest < ActiveSupport::TestCase
  class TestController
    include Sign::PasskeyOptionsFlow

    attr_accessor :params

    def initialize(params: {})
      @params = params
    end

    def before_passkey_options_request!
      true
    end

    def render_error(key, status)
      @error = { key: key, status: status }
    end

    def render(**args)
      @render_args = args
    end

    def test_options
      options
    end

    def error
      @error
    end

    def render_args
      @render_args
    end
  end

  test "returns error when identifier is blank" do
    controller = TestController.new(params: {})
    controller.test_options

    assert_equal "errors.webauthn.identifier_required", controller.error[:key]
    assert_equal :unprocessable_content, controller.error[:status]
  end

  test "returns error when identifier is empty string" do
    controller = TestController.new(params: { identifier: "" })
    controller.test_options

    assert_equal "errors.webauthn.identifier_required", controller.error[:key]
  end

  test "returns error when identifier is whitespace only" do
    controller = TestController.new(params: { identifier: "   " })
    controller.test_options

    assert_equal "errors.webauthn.identifier_required", controller.error[:key]
  end

  test "normalized_passkey_identifier strips whitespace" do
    controller = TestController.new(params: { identifier: "  test@example.com  " })

    assert_equal "test@example.com", controller.send(:normalized_passkey_identifier)
  end

  test "valid_passkey_identifier? returns true by default" do
    controller = TestController.new

    assert controller.send(:valid_passkey_identifier?, "test@example.com")
  end

  test "allow_passkey_options_for_actor? returns true by default" do
    controller = TestController.new

    assert controller.send(:allow_passkey_options_for_actor?, nil)
  end

  test "before_passkey_options_request! returns true by default" do
    controller = TestController.new

    assert controller.send(:before_passkey_options_request!)
  end

  test "passkey_identifier_invalid_error_key defaults to required error key" do
    controller = TestController.new

    assert_equal "errors.webauthn.identifier_required",
                 controller.send(:passkey_identifier_invalid_error_key)
  end

  test "find_active_passkey_actor raises NotImplementedError" do
    controller = TestController.new
    assert_raises(NotImplementedError) do
      controller.send(:find_active_passkey_actor, "test@example.com")
    end
  end

  test "active_passkeys_for_actor raises NotImplementedError" do
    controller = TestController.new
    assert_raises(NotImplementedError) do
      controller.send(:active_passkeys_for_actor, nil)
    end
  end
end
