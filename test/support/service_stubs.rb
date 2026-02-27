# typed: false
# frozen_string_literal: true

# Auto-stubs for external services in test environment.
# Stubs are applied per test to avoid cross-test global side effects.

module ServiceStubs
  def setup
    super
    return unless defined?(AwsSmsService)

    @original_aws_sms_send_message = AwsSmsService.method(:send_message)
    AwsSmsService.define_singleton_method(:send_message) do |to:, _message:, _subject: nil|
      Rails.logger.debug { "[TEST] AwsSmsService.send_message called with to: #{to}" }
      true
    end
  end

  def teardown
    if defined?(AwsSmsService) && @original_aws_sms_send_message
      AwsSmsService.define_singleton_method(:send_message, &@original_aws_sms_send_message)
    end
    super
  end
end

ActiveSupport.on_load(:active_support_test_case) { prepend ServiceStubs }
