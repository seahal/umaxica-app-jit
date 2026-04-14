# typed: false
# frozen_string_literal: true

require "test_helper"

class EmailValidationTest < ActiveSupport::TestCase
  class TestController
    include EmailValidation

    def test_validate_and_normalize_email(email)
      validate_and_normalize_email(email)
    end

    def test_valid_email_format?(email)
      valid_email_format?(email)
    end

    def test_identity_email_model
      identity_email_model
    end
  end

  test "validate_and_normalize_email returns normalized email" do
    controller = TestController.new
    result = controller.test_validate_and_normalize_email("  TEST@EXAMPLE.COM  ")

    assert_equal "test@example.com", result
  end

  test "validate_and_normalize_email returns nil for invalid email" do
    controller = TestController.new
    result = controller.test_validate_and_normalize_email("not-an-email")

    assert_nil result
  end

  test "valid_email_format? returns true for valid email" do
    controller = TestController.new

    assert controller.test_valid_email_format?("user@example.com")
  end

  test "valid_email_format? returns false for invalid email" do
    controller = TestController.new

    assert_not controller.test_valid_email_format?("not-an-email")
  end

  test "identity_email_model returns UserEmail" do
    controller = TestController.new

    assert_equal UserEmail, controller.test_identity_email_model
  end
end
