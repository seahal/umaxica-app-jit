# frozen_string_literal: true

class AwsSmsService
  def self.send_message(to:, message:, subject: nil)
    new.send_message(to: to, message: message, subject: subject)
  end

  def initialize
    @driver = Jit::Notification::Sms::AwsDriver.new(
      access_key_id: Rails.application.credentials.dig(:AWS, :ACCESS_KEY_ID),
      secret_access_key: Rails.application.credentials.dig(:AWS, :SECRET_ACCESS_KEY),
      region: Rails.application.config.aws_region || "ap-northeast-1",
    )
  end

  def send_message(to:, message:, subject: nil)
    @driver.send_message(to: to, message: message, subject: subject)
  end
end
