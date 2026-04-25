# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  module In
    class OtpResendStateTest < ActiveSupport::TestCase
      test "issue creates an encrypted token" do
        token = Sign::In::OtpResendState.issue(kind: "email", target: "user@example.com")

        assert_not_nil token
        assert_not_empty token
        assert_kind_of String, token
      end

      test "parse returns kind and target from valid token" do
        token = Sign::In::OtpResendState.issue(kind: "telephone", target: "+819012345678")

        result = Sign::In::OtpResendState.parse(token)

        assert_equal "telephone", result[:kind]
        assert_equal "+819012345678", result[:target]
      end

      test "parse returns nil for blank token" do
        assert_nil Sign::In::OtpResendState.parse(nil)
        assert_nil Sign::In::OtpResendState.parse("")
      end

      test "parse returns nil for tampered token" do
        assert_nil Sign::In::OtpResendState.parse("tampered-token-value")
      end

      test "parse raises on expired token" do
        token = Sign::In::OtpResendState.issue(kind: "email", target: "test@example.com")

        travel 31.minutes do
          assert_raises(NoMethodError) do
            Sign::In::OtpResendState.parse(token)
          end
        end
      end

      test "issue and parse with email kind" do
        token = Sign::In::OtpResendState.issue(kind: "email", target: "alice@example.com")
        result = Sign::In::OtpResendState.parse(token)

        assert_equal "email", result[:kind]
        assert_equal "alice@example.com", result[:target]
      end

      test "issue and parse with telephone kind" do
        token = Sign::In::OtpResendState.issue(kind: "telephone", target: "+818012345678")
        result = Sign::In::OtpResendState.parse(token)

        assert_equal "telephone", result[:kind]
        assert_equal "+818012345678", result[:target]
      end
    end
  end
end
