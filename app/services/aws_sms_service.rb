class AwsSmsService
  def self.send_message(to:, message:, subject: nil)
    new.send_message(to: to, message: message, subject: subject)
  end

  def initialize
    @client = Aws::SNS::Client.new(
      access_key_id: Rails.application.credentials.dig(:AWS, :ACCESS_KEY_ID),
      secret_access_key: Rails.application.credentials.dig(:AWS, :SECRET_ACCESS_KEY),
      region: Rails.application.config.aws_region || "ap-northeast-1"
    )
  end

  def send_message(to:, message:, subject: nil)
    validate_params(to: to, message: message)

    @client.publish({
                      phone_number: to,
                      message: message,
                      subject: subject || "SMS"
                    })
  end

  private

  def validate_params(to:, message:)
    raise ArgumentError, "Phone number is required" if to.blank?
    raise ArgumentError, "Message is required" if message.blank?
  end
end
