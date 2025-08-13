# frozen_string_literal: true

require "test_helper"

class EventPublisherTest < ActiveSupport::TestCase
  # test "publish_user_event returns skip message in test env" do
  #   msg = EventPublisher.publish_user_event("created", SecureRandom.uuid, foo: "bar")
  #   assert_equal "Skipped Kafka message publishing in test environment", msg
  # end
  #
  # test "publish_notification returns skip message in test env" do
  #   msg = EventPublisher.publish_notification("email.sent", subject: "hi")
  #   assert_equal "Skipped Kafka message publishing in test environment", msg
  # end
  #
  # test "publish_audit_log returns skip message in test env" do
  #   msg = EventPublisher.publish_audit_log("login", SecureRandom.uuid, ip: "127.0.0.1")
  #   assert_equal "Skipped Kafka message publishing in test environment", msg
  # end
  #
  # test "publish_to_topic returns skip message and does not raise" do
  #   data = { ping: "pong", n: 1 }
  #   msg = EventPublisher.publish_to_topic(:any_topic, data, key: "k", headers: { "x" => "y" })
  #   assert_equal "Skipped Kafka message publishing in test environment", msg
  # end
end

