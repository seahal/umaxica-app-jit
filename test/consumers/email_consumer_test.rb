# frozen_string_literal: true

require "test_helper"

class EmailConsumerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  def setup
    @consumer = EmailConsumer.new
    ActionMailer::Base.deliveries.clear
  end

  test "#valid_mailer? returns true for whitelisted mailers" do
    assert @consumer.send(:valid_mailer?, "Email::App::RegistrationMailer")
    assert @consumer.send(:valid_mailer?, "Email::Org::RegistrationMailer")
  end

  test "#valid_mailer? returns false for non-whitelisted mailers" do
    assert_not @consumer.send(:valid_mailer?, "InvalidMailer")
  end

  test "#process_email_message with valid payload sends an email" do
    payload = {
      "mailer_class" => "Email::App::RegistrationMailer",
      "params" => {
        "email_address" => "test@example.com",
        "hotp_token" => "123456"
      }
    }.to_json
    message = OpenStruct.new(raw_payload: payload)

    assert_emails 1 do
      @consumer.send(:process_email_message, message)
    end
  end

  test "#process_email_message with invalid mailer logs an error" do
    payload = { "mailer_class" => "InvalidMailer" }.to_json
    message = OpenStruct.new(raw_payload: payload)

    # Capture logged errors
    logged_errors = []

    # Create a custom logger for testing
    original_logger = Rails.logger
    test_logger = Logger.new(nil) # Logger that doesn't output anywhere
    test_logger.define_singleton_method(:error) { |msg| logged_errors << msg }

    begin
      Rails.instance_variable_set(:@logger, test_logger)
      @consumer.send(:process_email_message, message)
    ensure
      Rails.instance_variable_set(:@logger, original_logger)
    end

    assert_includes logged_errors, "Invalid mailer class: InvalidMailer"
  end

  test "#consume processes multiple messages and handles errors" do
    valid_payload = {
      "mailer_class" => "Email::App::RegistrationMailer",
      "params" => { "email_address" => "test@example.com", "hotp_token" => "123456" }
    }.to_json

    error_message_payload = "invalid-json"

    messages = [
      OpenStruct.new(raw_payload: valid_payload),
      OpenStruct.new(raw_payload: error_message_payload)
    ]

    # Create a test consumer with stubbed messages
    test_consumer = EmailConsumer.new
    test_consumer.define_singleton_method(:messages) { messages }

    # Capture logged errors
    logged_errors = []

    # Create a custom logger for testing
    original_logger = Rails.logger
    test_logger = Logger.new(nil) # Logger that doesn't output anywhere
    test_logger.define_singleton_method(:error) { |msg| logged_errors << msg }

    begin
      Rails.instance_variable_set(:@logger, test_logger)
      assert_emails 1 do
        test_consumer.consume
      end
    ensure
      Rails.instance_variable_set(:@logger, original_logger)
    end

    # Verify error was logged for invalid JSON
    assert logged_errors.any? { |msg| msg.start_with?("Failed to process email message:") }
  end
end
