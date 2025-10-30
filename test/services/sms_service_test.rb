# frozen_string_literal: true

require "test_helper"

class SmsServiceTest < ActiveSupport::TestCase
  def setup
    @original_provider = Rails.application.config.sms_provider
    Rails.application.config.sms_provider = "test"
  end

  def teardown
    Rails.application.config.sms_provider = @original_provider
  end

  # test "should send message using test provider" do
  #   result = SmsService.send_message(
  #     to: "+1234567890",
  #     message: "Test message",
  #     subject: "Test Subject"
  #   )

  #   assert_equal "+1234567890", result[:to]
  #   assert_equal "Test message", result[:message]
  #   assert_equal "Test Subject", result[:subject]
  #   assert_equal "test", result[:provider]
  #   assert_not_nil result[:sent_at]
  # end

  test "should use aws_sns provider when configured" do
    Rails.application.config.sms_provider = "aws_sns"

    # Reset provider cache
    SmsService.instance_variable_set(:@provider, nil)

    provider = SmsService.send(:provider)

    assert_instance_of SmsProviders::AwsSns, provider
  end

  test "should raise error for unsupported provider" do
    Rails.application.config.sms_provider = "unsupported"

    # Reset provider cache
    SmsService.instance_variable_set(:@provider, nil)

    assert_raises(RuntimeError) do
      SmsService.send(:provider)
    end
  end
end
