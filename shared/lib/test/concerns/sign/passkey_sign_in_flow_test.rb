# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  class PasskeySignInFlowTest < ActiveSupport::TestCase
    test "allow_passkey_sign_in? returns true by default" do
      controller = Class.new do
        include Sign::PasskeySignInFlow
      end.new

      assert controller.send(:allow_passkey_sign_in?, nil)
    end

    test "passkey_owner_mismatch_log_message returns default message" do
      controller = Class.new do
        include Sign::PasskeySignInFlow
      end.new

      assert_equal "WebAuthn: Credential not found or actor mismatch",
                   controller.send(:passkey_owner_mismatch_log_message)
    end

    test "passkey_sign_in_model raises NotImplementedError" do
      controller = Class.new do
        include Sign::PasskeySignInFlow
      end.new

      assert_raises(NotImplementedError) do
        controller.send(:passkey_sign_in_model)
      end
    end

    test "passkey_belongs_to_challenge_actor? raises NotImplementedError" do
      controller = Class.new do
        include Sign::PasskeySignInFlow
      end.new

      assert_raises(NotImplementedError) do
        controller.send(:passkey_belongs_to_challenge_actor?, nil, 1)
      end
    end

    test "perform_passkey_sign_in raises NotImplementedError" do
      controller = Class.new do
        include Sign::PasskeySignInFlow
      end.new

      assert_raises(NotImplementedError) do
        controller.send(:perform_passkey_sign_in, nil)
      end
    end
  end
end
