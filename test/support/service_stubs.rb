# typed: false
# frozen_string_literal: true

# Auto-stubs for external services in test environment
# These are applied globally to prevent actual external API calls.

module ServiceStubs
  # Set up service stubs for testing
  def self.setup
    # Stub AwsSmsService.send_message to prevent actual SMS sending
    AwsSmsService.define_singleton_method(:original_send_message, AwsSmsService.method(:send_message))
    AwsSmsService.define_singleton_method(:send_message) do |to:, message:, subject: nil|
      Rails.logger.debug { "[TEST] AwsSmsService.send_message called with to: #{to}" }
      true
    end
  end
end

# Apply stubs when this file is loaded
ServiceStubs.setup
