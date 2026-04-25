# typed: false
# frozen_string_literal: true

require "test_helper"

class VerificationTotpChecksTest < ActiveSupport::TestCase
  class FakeTotp
    attr_reader :private_key

    def initialize(private_key: "ABCDEF123456")
      @private_key = private_key
    end
  end

  class TestController
    include Sign::VerificationTotpChecks

    def initialize(code: nil, credentials: [])
      @code = code
      @credentials = credentials
    end

    def verification_params
      { code: @code }
    end

    def active_totp_credentials
      @credentials
    end

    def test_verify_totp
      verify_totp!
    end

    def verification_errors
      @verification_errors
    end
  end

  test "returns false for blank code" do
    controller = TestController.new(code: "")

    assert_not controller.test_verify_totp
    assert_includes controller.verification_errors, "確認コードが不正です"
  end

  test "returns false for non-numeric code" do
    controller = TestController.new(code: "abcdef")

    assert_not controller.test_verify_totp
    assert_includes controller.verification_errors, "確認コードが不正です"
  end

  test "returns false for code with wrong length" do
    controller = TestController.new(code: "12345")

    assert_not controller.test_verify_totp
    assert_includes controller.verification_errors, "確認コードが不正です"
  end

  test "returns false for code with 7 digits" do
    controller = TestController.new(code: "1234567")

    assert_not controller.test_verify_totp
    assert_includes controller.verification_errors, "確認コードが不正です"
  end

  test "returns false when no active credentials" do
    controller = TestController.new(code: "123456", credentials: [])

    assert_not controller.test_verify_totp
    assert_includes controller.verification_errors, "確認コードが正しくありません"
  end

  test "raises NotImplementedError when active_totp_credentials not defined" do
    controller = Class.new do
      include Sign::VerificationTotpChecks

      define_method(:verification_params) do
        { code: "123456" }
      end
    end.new

    assert_raises(NotImplementedError) do
      controller.send(:verify_totp!)
    end
  end
end
