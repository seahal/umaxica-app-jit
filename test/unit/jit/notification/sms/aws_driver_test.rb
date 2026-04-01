# typed: false
# frozen_string_literal: true

require "test_helper"

module Jit
  module Notification
    module Sms
      class AwsDriverTest < ActiveSupport::TestCase
        test "raises ArgumentError when phone number is blank" do
          driver = AwsDriver.new(access_key_id: "key", secret_access_key: "secret", region: "us-east-1")

          assert_raises(ArgumentError) do
            driver.send_message(to: "", message: "Hello")
          end

          assert_raises(ArgumentError) do
            driver.send_message(to: nil, message: "Hello")
          end
        end

        test "raises ArgumentError when message is blank" do
          driver = AwsDriver.new(access_key_id: "key", secret_access_key: "secret", region: "us-east-1")

          assert_raises(ArgumentError) do
            driver.send_message(to: "+1234567890", message: "")
          end

          assert_raises(ArgumentError) do
            driver.send_message(to: "+1234567890", message: nil)
          end
        end

        test "sends message with valid parameters" do
          mock_client = Minitest::Mock.new
          mock_client.expect(
            :publish, OpenStruct.new(message_id: "test-id"), [{
              phone_number: "+1234567890",
              message: "Hello World",
              subject: "SMS",
            }],
          )

          driver = AwsDriver.new(access_key_id: "key", secret_access_key: "secret", region: "us-east-1")
          driver.instance_variable_set(:@client, mock_client)

          result = driver.send_message(to: "+1234567890", message: "Hello World")

          assert_equal "test-id", result.message_id
          mock_client.verify
        end

        test "sends message with custom subject" do
          mock_client = Minitest::Mock.new
          mock_client.expect(
            :publish, OpenStruct.new(message_id: "test-id"), [{
              phone_number: "+1234567890",
              message: "Hello World",
              subject: "Custom Subject",
            }],
          )

          driver = AwsDriver.new(access_key_id: "key", secret_access_key: "secret", region: "us-east-1")
          driver.instance_variable_set(:@client, mock_client)

          result = driver.send_message(to: "+1234567890", message: "Hello World", subject: "Custom Subject")

          assert_equal "test-id", result.message_id
          mock_client.verify
        end
      end
    end
  end
end
