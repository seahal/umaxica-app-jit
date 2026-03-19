# typed: false
# frozen_string_literal: true

require "test_helper"
require Rails.root.join("app/subscribers/jwt_anomaly_subscriber")

class JwtAnomalySubscriberTest < ActiveSupport::TestCase
  fixtures :jwt_occurrences

  class MockEvent
    attr_reader :name, :payload, :time

    def initialize(name:, payload:, time: nil)
      @name = name
      @payload = payload
      @time = time
    end
  end

  test "emit does nothing when event name does not match" do
    mock_event = MockEvent.new(
      name: "other.event",
      payload: { code: "MALFORMED_TOKEN" },
    )

    subscriber = JwtAnomalySubscriber.new
    assert_no_difference "JwtAnomalyEvent.count" do
      subscriber.emit(mock_event)
    end
  end

  test "emit does nothing when event does not respond to name" do
    payload = { code: "MALFORMED_TOKEN" }
    subscriber = JwtAnomalySubscriber.new

    assert_no_difference "JwtAnomalyEvent.count" do
      subscriber.emit(payload)
    end
  end

  test "emit does nothing when code is blank" do
    mock_event = MockEvent.new(
      name: "jwt.anomaly.detected",
      payload: { code: "" },
    )

    subscriber = JwtAnomalySubscriber.new
    assert_no_difference "JwtAnomalyEvent.count" do
      subscriber.emit(mock_event)
    end
  end

  test "emit handles missing payload gracefully" do
    mock_event = MockEvent.new(
      name: "jwt.anomaly.detected",
      payload: nil,
    )

    subscriber = JwtAnomalySubscriber.new
    assert_no_difference "JwtAnomalyEvent.count" do
      subscriber.emit(mock_event)
    end
  end

  test "emit creates anomaly event when occurrence exists" do # rubocop:disable Minitest/MultipleAssertions
    occurred_at = Time.current.change(usec: 0)
    mock_event = MockEvent.new(
      name: "jwt.anomaly.detected",
      payload: {
        code: "AUTH_USER_MALFORMED_TOKEN",
        request_host: "sign.app.localhost",
        kid: "kid-1",
        alg: "ES384",
        typ: "JWT",
        iss: "jit",
        jti: "jti-123",
        error_class: "JWT::DecodeError",
        error_message: "invalid token",
        extra: "kept",
      },
      time: occurred_at,
    )

    subscriber = JwtAnomalySubscriber.new

    assert_difference "JwtAnomalyEvent.count", 1 do
      subscriber.emit(mock_event)
    end

    event = JwtAnomalyEvent.order(:id).last

    assert_equal jwt_occurrences(:auth_user_malformed_token), event.jwt_occurrence
    assert_equal "AUTH_USER_MALFORMED_TOKEN", event.code
    assert_equal "sign.app.localhost", event.request_host
    assert_equal "kid-1", event.kid
    assert_equal "ES384", event.alg
    assert_equal "JWT", event.typ
    assert_equal "jit", event.issuer
    assert_equal "jti-123", event.jti
    assert_equal "JWT::DecodeError", event.error_class
    assert_equal "invalid token", event.error_message
    assert_equal({ "extra" => "kept" }, event.metadata)
    assert_equal occurred_at, event.occurred_at
  end

  test "emit does nothing when occurrence is not found" do
    mock_event = MockEvent.new(
      name: "jwt.anomaly.detected",
      payload: { code: "UNKNOWN_CODE" },
    )

    subscriber = JwtAnomalySubscriber.new

    assert_no_difference "JwtAnomalyEvent.count" do
      subscriber.emit(mock_event)
    end
  end

  test "build_metadata strips known top-level event fields" do
    subscriber = JwtAnomalySubscriber.new

    metadata = subscriber.send(
      :build_metadata,
      {
        :code => "AUTH_USER_MALFORMED_TOKEN",
        "request_host" => "sign.app.localhost",
        :kid => "kid-1",
        :alg => "ES384",
        :typ => "JWT",
        :iss => "jit",
        :jti => "jti-123",
        :error_class => "JWT::DecodeError",
        :error_message => "invalid token",
        :extra => "kept",
        "another" => "kept-too",
      },
    )

    assert_equal({ :extra => "kept", "another" => "kept-too" }, metadata)
  end

  test "emit logs and swallows errors from event creation" do
    logged_message = nil
    mock_event = MockEvent.new(
      name: "jwt.anomaly.detected",
      payload: { code: "AUTH_USER_MALFORMED_TOKEN" },
    )

    JwtAnomalyEvent.stub :create!, ->(**) { raise StandardError, "explode" } do
      Rails.logger.stub :error, ->(message) { logged_message = message } do
        JwtAnomalySubscriber.new.emit(mock_event)
      end
    end

    assert_includes logged_message, "JwtAnomalySubscriber failed"
  end
end
