# typed: false
# frozen_string_literal: true

require "test_helper"

module SocialAuth
  class ProviderErrorTest < ActiveSupport::TestCase
    test "ProviderError can be instantiated with default message" do
      error = ProviderError.new
      assert_equal "プロバイダーとの通信中にエラーが発生しました", error.message
      assert_equal :bad_request, error.status_code
    end

    test "ProviderError can be instantiated with custom message" do
      error = ProviderError.new("custom.error.key")
      assert_equal "カスタムエラー", error.message
    end

    test "ProviderError includes context" do
      error = ProviderError.new("errors.social_auth.provider_error", provider: "google")
      assert_equal :bad_request, error.status_code
    end
  end
end
