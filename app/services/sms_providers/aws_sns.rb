# frozen_string_literal: true

module SmsProviders
  class AwsSns < Base
    def send_message(to:, message:, subject: nil)
      validate_params(to: to, message: message, subject: subject)

      client.publish({
                       phone_number: to,
                       message: message,
                       subject: subject || "SMS"
                     })
    end

    private

    def client
      @client ||= Aws::SNS::Client.new(
        access_key_id: Rails.application.credentials.dig(:AWS, :ACCESS_KEY_ID),
        secret_access_key: Rails.application.credentials.dig(:AWS, :SECRET_ACCESS_KEY),
        region: Rails.application.config.aws_region || "ap-northeast-1"
      )
    end
  end
end
