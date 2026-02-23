# typed: false
# frozen_string_literal: true

require "test_helper"
require "jit/utils/email_validator"

module Jit
  module Utils
    class EmailValidatorTest < ActiveSupport::TestCase
      test "normalize returns nil for blank email" do
        assert_nil EmailValidator.normalize(nil)
        assert_nil EmailValidator.normalize("")
        assert_nil EmailValidator.normalize("  ")
      end

      test "normalize downcases and strips email" do
        assert_equal "user@example.com", EmailValidator.normalize(" USER@Example.COM ")
      end

      test "normalize returns nil for invalid email" do
        assert_nil EmailValidator.normalize("invalid-email")
        assert_nil EmailValidator.normalize("user@")
        assert_nil EmailValidator.normalize("@example.com")
      end

      test "valid? returns true for valid email" do
        assert EmailValidator.valid?("user@example.com")
        assert EmailValidator.valid?("user.name+tag@example.co.jp")
      end

      test "valid? returns false for invalid email" do
        assert_not EmailValidator.valid?("invalid")
        assert_not EmailValidator.valid?("")
        assert_not EmailValidator.valid?(nil)
      end
    end
  end
end
