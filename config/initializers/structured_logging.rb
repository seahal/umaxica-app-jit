# typed: false
# frozen_string_literal: true

# Rails 8.1 Structured Logging Configuration
#
# Sets up JSON log formatting and a Rails.event subscriber for structured event output.
# This uses Rails 8.1's native structured logging (config.active_support.structured_logging = true)
# without any external gems.

# JSON Log Formatter - outputs each log line as a single JSON object.
json_formatter =
  proc do |severity, datetime, _progname, msg|
    payload = {
      timestamp: datetime.utc.iso8601(3),
      severity: severity,
      message: msg.is_a?(String) ? msg.strip : msg.inspect,
    }

    "#{payload.to_json}\n"
  end

Rails.application.configure do
  config.log_formatter = json_formatter
end

# Structured Event Subscriber - forwards Rails.event emissions to the logger as JSON.
ActiveSupport.on_load(:after_initialize) do
  if defined?(Rails.event) && Rails.event.respond_to?(:subscribe)
    subscriber =
      Class.new do
        define_method(:emit) do |event|
          payload =
            if event.respond_to?(:time)
              {
                timestamp: event.time.utc.iso8601(3),
                event: event.name,
                tags: event.try(:tags),
                context: event.try(:context),
                data: event.try(:payload),
                source: event.try(:source_location),
              }
            else
              { timestamp: Time.now.utc.iso8601(3), event: event.to_json }
            end

          Rails.logger.info(payload.compact.to_json)
        end
      end

    Rails.event.subscribe(subscriber.new)
  end
end
