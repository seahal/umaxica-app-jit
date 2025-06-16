# frozen_string_literal: true

# Karafka configuration and integration with Rails

# Only configure if Karafka is being used (not during asset precompilation, tests, etc.)
if defined?(Karafka) && !Rails.env.test?
  # Configure ActiveJob to use Karafka as the queue adapter
  Rails.application.configure do
    config.active_job.queue_adapter = :karafka
  end

  # Add custom queue names for different job priorities
  ActiveJob::Base.queue_name_prefix = Rails.env.production? ? 'production' : 'development'

  # Hook into Rails application lifecycle
  Rails.application.config.after_initialize do
    # Ensure Karafka producer is properly configured for the Rails environment
    if Rails.env.development?
      # In development, we might want to log all produced messages
      # Note: The event name might vary depending on Karafka/WaterDrop version
      begin
        Karafka.producer.monitor.subscribe('message.produced') do |event|
          Rails.logger.debug "Kafka message produced: #{event[:message][:topic]}"
        end
      rescue Karafka::Core::Monitoring::Notifications::EventNotRegistered
        # Silently skip if event is not available in this version
      end
    end

    # Subscribe to producer errors for monitoring
    begin
      Karafka.producer.monitor.subscribe('error.occurred') do |event|
        Rails.logger.error "Kafka producer error: #{event[:error]}"
        
        # In production, you might want to send this to an error tracking service
        # Sentry.capture_exception(event[:error]) if defined?(Sentry)
      end
    rescue Karafka::Core::Monitoring::Notifications::EventNotRegistered
      # Silently skip if event is not available in this version
    end
  end

  # Helper module for model integration
  module KafkaEventable
    extend ActiveSupport::Concern

    included do
      after_create :publish_created_event, if: :should_publish_events?
      after_update :publish_updated_event, if: :should_publish_events?
      after_destroy :publish_destroyed_event, if: :should_publish_events?
    end

    private

    def should_publish_events?
      # Override this method in models to control when events are published
      !Rails.env.test?
    end

    def publish_created_event
      EventPublisher.publish_audit_log(
        'create',
        current_user_id,
        resource_type: self.class.name,
        resource_id: id,
        changes: changes
      )
    rescue StandardError => e
      Rails.logger.error "Failed to publish created event for #{self.class.name}:#{id}: #{e.message}"
    end

    def publish_updated_event
      return unless saved_changes.any?

      EventPublisher.publish_audit_log(
        'update',
        current_user_id,
        resource_type: self.class.name,
        resource_id: id,
        changes: saved_changes
      )
    rescue StandardError => e
      Rails.logger.error "Failed to publish updated event for #{self.class.name}:#{id}: #{e.message}"
    end

    def publish_destroyed_event
      EventPublisher.publish_audit_log(
        'delete',
        current_user_id,
        resource_type: self.class.name,
        resource_id: id
      )
    rescue StandardError => e
      Rails.logger.error "Failed to publish destroyed event for #{self.class.name}:#{id}: #{e.message}"
    end

    def current_user_id
      # This should be implemented based on your authentication system
      # For example, using Current attributes or thread-local storage
      Current.user&.id
    end
  end
end