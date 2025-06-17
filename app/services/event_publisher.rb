# frozen_string_literal: true

# Service for publishing events to Kafka topics
class EventPublisher
  class << self
    # Publish user-related events
    def publish_user_event(event_type, user_id, data = {})
      event_data = {
        event_type: event_type,
        user_id: user_id,
        timestamp: Time.current.iso8601,
        **data
      }

      publish_to_topic(:user_events, event_data, key: user_id.to_s)
    end

    # Publish notification events
    def publish_notification(type, data = {})
      notification_data = {
        type: type,
        timestamp: Time.current.iso8601,
        **data
      }

      publish_to_topic(:notifications, notification_data)
    end

    # Publish audit log events
    def publish_audit_log(action, user_id, data = {})
      audit_data = {
        action: action,
        user_id: user_id,
        timestamp: Time.current.iso8601,
        **data
      }

      publish_to_topic(:audit_logs, audit_data, key: user_id.to_s)
    end

    # Generic method to publish to any topic
    def publish_to_topic(topic, data, key: nil, headers: {})
      # Skip publishing in test environment or if Karafka is not available
      return Rails.logger.debug "Skipped Kafka message publishing in test environment" if Rails.env.test?
      return Rails.logger.warn "Karafka not available" unless defined?(Karafka)

      message = {
        topic: topic,
        payload: data.to_json,
        headers: default_headers.merge(headers)
      }

      message[:key] = key if key

      Karafka.producer.produce_sync(message)

      Rails.logger.debug "Published message to topic '#{topic}': #{data}"
    rescue StandardError => e
      Rails.logger.error "Failed to publish message to topic '#{topic}': #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Optionally store failed messages for retry
      # FailedMessage.create(
      #   topic: topic,
      #   payload: data.to_json,
      #   error: e.message,
      #   headers: headers
      # )

      raise
    end

    private

    def default_headers
      {
        "content-type" => "application/json",
        "producer" => "umaxica-app",
        "environment" => Rails.env,
        "version" => "1.0"
      }
    end
  end
end
