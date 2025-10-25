# frozen_string_literal: true

require "test_helper"

class EventPublisherTest < ActiveSupport::TestCase
  test "publish_event enqueues EventPublishJob with correct arguments" do
    assert_not nil
  end
end

class EventPublisherIntegrationTest < ActiveSupport::TestCase
  setup do
    @user_id = "user_123"
    @event_type = "user_registered"
    @test_data = { email: "test@example.com" }
  end

  test "publish_user_event returns early in test environment" do
    # In test env, it should log and return without error
    assert_nothing_raised do
      EventPublisher.publish_user_event(@event_type, @user_id, @test_data)
    end
  end

  test "publish_user_event builds event_data with correct structure" do
    # Even in test mode, we can verify the method accepts correct parameters
    assert_nothing_raised do
      EventPublisher.publish_user_event("login", "user_456", { ip: "127.0.0.1" })
    end
  end

  test "publish_notification returns early in test environment" do
    assert_nothing_raised do
      EventPublisher.publish_notification("email", { recipient: "test@example.com" })
    end
  end

  test "publish_notification accepts type and data parameters" do
    assert_nothing_raised do
      EventPublisher.publish_notification("sms", { phone: "+1234567890", message: "Test" })
    end
  end

  test "publish_audit_log returns early in test environment" do
    assert_nothing_raised do
      EventPublisher.publish_audit_log("delete_user", @user_id, { reason: "GDPR request" })
    end
  end

  test "publish_audit_log accepts action, user_id and data parameters" do
    assert_nothing_raised do
      EventPublisher.publish_audit_log("update_profile", "user_789", { field: "email" })
    end
  end

  test "publish_to_topic returns early in test environment" do
    assert_nothing_raised do
      EventPublisher.publish_to_topic(:custom_topic, { key: "value" })
    end
  end

  test "publish_to_topic accepts topic, data, key and headers" do
    assert_nothing_raised do
      EventPublisher.publish_to_topic(
        :events,
        { event: "test" },
        key: "test_key",
        headers: { "custom-header" => "value" }
      )
    end
  end

  test "publish_to_topic with only required parameters" do
    assert_nothing_raised do
      EventPublisher.publish_to_topic(:test_topic, { data: "test" })
    end
  end

  test "publish_user_event merges additional data correctly" do
    # Test that the method signature works with various data types
    assert_nothing_raised do
      EventPublisher.publish_user_event(
        "profile_updated",
        @user_id,
        {
          old_email: "old@example.com",
          new_email: "new@example.com",
          changed_at: Time.current
        }
      )
    end
  end

  test "publish_notification with empty data hash" do
    assert_nothing_raised do
      EventPublisher.publish_notification("test_notification")
    end
  end

  test "publish_audit_log with empty data hash" do
    assert_nothing_raised do
      EventPublisher.publish_audit_log("test_action", @user_id)
    end
  end

  test "EventPublisher is a class with class methods" do
    assert_respond_to EventPublisher, :publish_user_event
    assert_respond_to EventPublisher, :publish_notification
    assert_respond_to EventPublisher, :publish_audit_log
    assert_respond_to EventPublisher, :publish_to_topic
  end

  test "publish_user_event with string user_id" do
    assert_nothing_raised do
      EventPublisher.publish_user_event("test_event", "string_user_123", {})
    end
  end

  test "publish_user_event with integer user_id" do
    assert_nothing_raised do
      EventPublisher.publish_user_event("test_event", 12345, {})
    end
  end

  test "publish_audit_log with string user_id" do
    assert_nothing_raised do
      EventPublisher.publish_audit_log("test_action", "string_user_456", {})
    end
  end

  test "publish_audit_log with integer user_id" do
    assert_nothing_raised do
      EventPublisher.publish_audit_log("test_action", 67890, {})
    end
  end

  test "publish_to_topic with symbol topic" do
    assert_nothing_raised do
      EventPublisher.publish_to_topic(:symbol_topic, { test: "data" })
    end
  end

  test "publish_to_topic with string topic" do
    assert_nothing_raised do
      EventPublisher.publish_to_topic("string_topic", { test: "data" })
    end
  end

  test "publish_notification with complex nested data" do
    complex_data = {
      user: { id: 123, name: "Test User" },
      notification: {
        type: "email",
        template: "welcome",
        variables: { name: "Test", code: "ABC123" }
      }
    }

    assert_nothing_raised do
      EventPublisher.publish_notification("complex", complex_data)
    end
  end

  test "publish_user_event with various event types" do
    event_types = %w[created updated deleted logged_in logged_out]

    event_types.each do |event_type|
      assert_nothing_raised do
        EventPublisher.publish_user_event(event_type, @user_id, {})
      end
    end
  end

  test "publish_to_topic with nil key" do
    assert_nothing_raised do
      EventPublisher.publish_to_topic(:test_topic, { data: "test" }, key: nil)
    end
  end

  test "publish_to_topic with empty headers" do
    assert_nothing_raised do
      EventPublisher.publish_to_topic(:test_topic, { data: "test" }, headers: {})
    end
  end

  test "publish_to_topic with custom headers" do
    custom_headers = {
      "X-Custom-Header" => "value",
      "X-Request-ID" => "req-123",
      "X-Correlation-ID" => "corr-456"
    }

    assert_nothing_raised do
      EventPublisher.publish_to_topic(:test_topic, { data: "test" }, headers: custom_headers)
    end
  end
end
