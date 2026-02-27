# typed: false
# frozen_string_literal: true

require "test_helper"

module SocialAuth
  class ReauthRequiredErrorTest < ActiveSupport::TestCase
    test "ReauthRequiredError can be instantiated" do
      error = ReauthRequiredError.new

      assert_match(
        /Translation missing: ja.errors.social_auth.reauth_required|この操作には最近の再認証が必要です/,
        error.message,
      )
      assert_equal :forbidden, error.status_code
    end

    test "ReauthRequiredError includes return_to context" do
      error = ReauthRequiredError.new(return_to: "/some/path")

      assert_equal :forbidden, error.status_code
    end
  end
end
