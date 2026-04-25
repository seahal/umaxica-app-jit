# typed: false
# frozen_string_literal: true

require "test_helper"

module Security
  class JwtAnomalyReporterTest < ActiveSupport::TestCase
    test "report_auth calls report with auth context for user" do
      recorded = []
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_auth(
          resource_type: "user",
          host: "sign.app.localhost",
          reason: "MISSING_ISS",
        )
      end

      assert_equal 1, recorded.size
      assert_equal "jwt.anomaly.detected", recorded.first[0]
      assert_equal "AUTH_USER_MISSING_ISS", recorded.first[1][:code]
    end

    test "report_auth calls report with auth context for staff" do
      recorded = []
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_auth(
          resource_type: "staff",
          host: "sign.org.localhost",
          reason: "MISSING_AUD",
        )
      end

      assert_equal "AUTH_STAFF_MISSING_AUD", recorded.first[1][:code]
    end

    test "report_preference calls report with app context" do
      recorded = []
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_preference(
          host: "app.localhost",
          reason: "MISSING_EXP",
        )
      end

      assert_equal "APP_PREFERENCE_MISSING_EXP", recorded.first[1][:code]
    end

    test "report_preference calls report with com context" do
      recorded = []
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_preference(
          host: "com.localhost",
          reason: "MISSING_SUB",
        )
      end

      assert_equal "COM_PREFERENCE_MISSING_SUB", recorded.first[1][:code]
    end

    test "report_preference calls report with org context" do
      recorded = []
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_preference(
          host: "org.localhost",
          reason: "MISSING_JTI",
        )
      end

      assert_equal "ORG_PREFERENCE_MISSING_JTI", recorded.first[1][:code]
    end

    test "report_preference returns nil context for unknown host" do
      recorded = []
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_preference(
          host: "unknown.localhost",
          reason: "MISSING_SID",
        )
      end

      assert_empty recorded
    end

    test "report does nothing when context is blank" do
      recorded = []
      Rails.event.stub(:notify, ->(name, **) { recorded << name }) do
        Jwt::AnomalyReporter.send(
          :report, context: nil, host: "host", header: {}, payload: {}, reason: "REASON",
                   error: nil, extra: {},
        )
      end

      assert_empty recorded
    end

    test "report does nothing when reason is blank" do
      recorded = []
      Rails.event.stub(:notify, ->(name, **) { recorded << name }) do
        Jwt::AnomalyReporter.send(
          :report, context: "CTX", host: "host", header: {}, payload: {}, reason: nil,
                   error: nil, extra: {},
        )
      end

      assert_empty recorded
    end

    test "report includes header fields in payload" do
      recorded = []
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_auth(
          resource_type: "user",
          host: "sign.app.localhost",
          header: { "kid" => "key-1", "alg" => "RS256" },
          reason: "MISSING_TYP",
        )
      end

      assert_equal "key-1", recorded.first[1][:kid]
      assert_equal "RS256", recorded.first[1][:alg]
    end

    test "report includes payload fields" do
      recorded = []
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_auth(
          resource_type: "user",
          host: "sign.app.localhost",
          payload: { "iss" => "test-issuer", "aud" => "test-aud", "jti" => "jti-123" },
          reason: "MISSING_TYP",
        )
      end

      assert_equal "test-issuer", recorded.first[1][:iss]
      assert_equal "test-aud", recorded.first[1][:aud]
      assert_equal "jti-123", recorded.first[1][:jti]
    end

    test "report includes error info" do
      recorded = []
      error = JWT::DecodeError.new("Missing required claim iss")
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_auth(
          resource_type: "user",
          host: "sign.app.localhost",
          reason: "MISSING_ISS",
          error: error,
        )
      end

      assert_equal "JWT::DecodeError", recorded.first[1][:error_class]
      assert_equal "Missing required claim iss", recorded.first[1][:error_message]
    end

    test "report includes extra fields" do
      recorded = []
      Rails.event.stub(:notify, ->(name, payload) { recorded << [name, payload] }) do
        Jwt::AnomalyReporter.report_auth(
          resource_type: "user",
          host: "sign.app.localhost",
          reason: "MISSING_ISS",
          extra: { custom_field: "value" },
        )
      end

      assert_equal "value", recorded.first[1][:custom_field]
    end

    test "reason_for_missing_claim maps iss to MISSING_ISS" do
      assert_equal "MISSING_ISS", Jwt::AnomalyReporter.reason_for_missing_claim("Missing required claim iss")
    end

    test "reason_for_missing_claim maps aud to MISSING_AUD" do
      assert_equal "MISSING_AUD", Jwt::AnomalyReporter.reason_for_missing_claim("Missing required claim aud")
    end

    test "reason_for_missing_claim returns DECODE_ERROR for unknown claim" do
      assert_equal "DECODE_ERROR", Jwt::AnomalyReporter.reason_for_missing_claim("Some other error")
    end

    test "auth_context returns nil for unknown resource type" do
      assert_nil Jwt::AnomalyReporter.auth_context("unknown")
    end

    test "preference_context returns nil for unrecognized host" do
      assert_nil Jwt::AnomalyReporter.preference_context("unknown.host")
    end

    test "report rescues from errors and logs via Rails.event.error" do
      Rails.event.stub(:notify, ->(**) { raise StandardError, "notify failed" }) do
        Rails.event.stub(:error, ->(name, **data) { @error_logged = [name, data].freeze }) do
          Jwt::AnomalyReporter.report_auth(
            resource_type: "user",
            host: "sign.app.localhost",
            reason: "MISSING_ISS",
          )
        end
      end

      assert_equal "security.jwt.anomaly_report_failed", @error_logged[0]
      assert_predicate @error_logged[1][:error_class], :present?
    end
  end
end
