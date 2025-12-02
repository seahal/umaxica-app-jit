# frozen_string_literal: true

require "test_helper"

class SmsProviders::TestProviderTest < ActiveSupport::TestCase
  def setup
    @provider = SmsProviders::Test.new
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should send message and return result" do
    result = @provider.send_message(
      to: "+1234567890",
      message: "Test message",
      subject: "Test Subject"
    )

    assert_equal "+1234567890", result[:to]
    assert_equal "Test message", result[:message]
    assert_equal "Test Subject", result[:subject]
    assert_equal "test", result[:provider]
    assert_not_nil result[:sent_at]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should validate required parameters" do
    assert_raises(ArgumentError) do
      @provider.send_message(to: "", message: "Test message")
    end

    assert_raises(ArgumentError) do
      @provider.send_message(to: "+1234567890", message: "")
    end
  end
end
