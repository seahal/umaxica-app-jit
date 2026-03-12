# typed: false
# frozen_string_literal: true

require "test_helper"

module SocialAuth
  class ConflictErrorTest < ActiveSupport::TestCase
    test "ConflictError can be instantiated with default message" do
      error = ConflictError.new

      assert_equal :conflict, error.status_code
    end

    test "ConflictError can be instantiated with default i18n key" do
      error = ConflictError.new("errors.social_auth.conflict")

      assert_equal :conflict, error.status_code
    end

    test "ConflictError includes context" do
      error = ConflictError.new("errors.social_auth.conflict", user_id: 123)

      assert_equal :conflict, error.status_code
      assert_equal 123, error.context[:user_id]
    end
  end
end
