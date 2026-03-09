# typed: false
# frozen_string_literal: true

class AwsSmsService
  def self.send_message(to:, message:, subject: nil)
    new.send_message(to: to, message: message, subject: subject)
  end

  def initialize
    @driver = Jit::Notification::Sms::AwsDriver.new(
      access_key_id: Rails.app.creds.require(:AWS_ACCESS_KEY_ID),
      secret_access_key: Rails.app.creds.require(:AWS_SECRET_ACCESS_KEY),
      region: Rails.application.config.aws_region || "ap-northeast-1",
    )
  end

  def send_message(to:, message:, subject: nil)
    @driver.send_message(to: to, message: message, subject: subject)
  end
end
