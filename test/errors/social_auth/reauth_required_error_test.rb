# frozen_string_literal: true

require "test_helper"

module SocialAuth
  class ReauthRequiredErrorTest < ActiveSupport::TestCase
    test "ReauthRequiredError can be instantiated" do
      error = ReauthRequiredError.new
      assert_equal "この操作には最近の再認証が必要です。もう一度認証してください。", error.message
      assert_equal :forbidden, error.status_code
    end

    test "ReauthRequiredError includes return_to context" do
      error = ReauthRequiredError.new(return_to: "/some/path")
      assert_equal :forbidden, error.status_code
    end
  end
end
