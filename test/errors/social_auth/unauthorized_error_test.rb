# typed: false
# frozen_string_literal: true

require "test_helper"

module SocialAuth
  class UnauthorizedErrorTest < ActiveSupport::TestCase
    test "initializes with default i18n key" do
      error = UnauthorizedError.new

      assert_equal "errors.social_auth.unauthorized", error.i18n_key
    end

    test "has unauthorized status code" do
      error = UnauthorizedError.new

      assert_equal :unauthorized, error.status_code
    end

    test "initializes with custom i18n key" do
      error = UnauthorizedError.new("custom.unauthorized")

      assert_equal "custom.unauthorized", error.i18n_key
    end

    test "initializes with context" do
      error = UnauthorizedError.new("errors.social_auth.unauthorized", reason: "state_mismatch")

      assert_equal({ reason: "state_mismatch" }, error.context)
    end

    test "is a subclass of BaseError" do
      assert_kind_of BaseError, UnauthorizedError.new
    end
  end
end
