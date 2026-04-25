# typed: false
# frozen_string_literal: true

require "aws-sdk-sns"

module Notification
  module Sms
    class AwsDriver
      def initialize(access_key_id:, secret_access_key:, region:)
        @client = Aws::SNS::Client.new(
          access_key_id: access_key_id,
          secret_access_key: secret_access_key,
          region: region,
        )
      end

      def send_message(to:, message:, subject: nil)
        validate_params(to: to, message: message)

        @client.publish(
          {
            phone_number: to,
            message: message,
            subject: subject || "SMS",
          },
        )
      end

      private

      def validate_params(to:, message:)
        raise ArgumentError, "Phone number is required" if to.blank?
        raise ArgumentError, "Message is required" if message.blank?
      end
    end
  end
end
