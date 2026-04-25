# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  module In
    class OtpResendServiceTest < ActiveSupport::TestCase
      test "returns invalid response for blank state" do
        service = OtpResendService.new(kind: "email", state: "")
        result = service.call

        assert_equal :bad_request, result.status
        assert_not result.resendable
        assert_equal 30, result.retry_after
      end

      test "returns invalid response for nil state" do
        service = OtpResendService.new(kind: "email", state: nil)
        result = service.call

        assert_equal :bad_request, result.status
        assert_not result.resendable
      end

      test "returns invalid response for tampered state" do
        service = OtpResendService.new(kind: "email", state: "tampered-token")
        result = service.call

        assert_equal :bad_request, result.status
        assert_not result.resendable
      end

      test "returns invalid response when kind does not match state" do
        token = OtpResendState.issue(kind: "email", target: "test@example.com")
        service = OtpResendService.new(kind: "telephone", state: token)
        result = service.call

        assert_equal :bad_request, result.status
        assert_not result.resendable
      end

      test "Response struct has expected attributes" do
        response = OtpResendService::Response.new(
          status: :ok, resendable: true, retry_after: 0,
        )

        assert_equal :ok, response.status
        assert response.resendable
        assert_equal 0, response.retry_after
      end

      test "EMAIL_CAP_SECONDS is 15 minutes" do
        assert_equal 15.minutes.to_i, OtpResendService::EMAIL_CAP_SECONDS
      end

      test "TELEPHONE_CAP_SECONDS is 60 minutes" do
        assert_equal 60.minutes.to_i, OtpResendService::TELEPHONE_CAP_SECONDS
      end

      test "BASE_SECONDS is 30" do
        assert_equal 30, OtpResendService::BASE_SECONDS
      end
    end
  end
end
