# typed: false
# frozen_string_literal: true

require "test_helper"

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
end
