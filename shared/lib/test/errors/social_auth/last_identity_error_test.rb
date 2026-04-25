# typed: false
# frozen_string_literal: true

require "test_helper"

module SocialAuth
  class LastIdentityErrorTest < ActiveSupport::TestCase
    test "initializes with default i18n key" do
      error = LastIdentityError.new

      assert_equal "errors.social_auth.last_identity", error.i18n_key
    end

    test "has unprocessable_entity status code" do
      error = LastIdentityError.new

      assert_equal :unprocessable_entity, error.status_code
    end

    test "initializes with custom i18n key" do
      error = LastIdentityError.new("custom.last_identity")

      assert_equal "custom.last_identity", error.i18n_key
    end

    test "initializes with context" do
      error = LastIdentityError.new("errors.social_auth.last_identity", method: "email")

      assert_equal({ method: "email" }, error.context)
    end

    test "is a subclass of BaseError" do
      assert_kind_of BaseError, LastIdentityError.new
    end
  end
end
