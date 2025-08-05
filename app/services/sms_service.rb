# frozen_string_literal: true

class SmsService
  class << self
    def send_message(to:, message:, subject: nil)
      provider.send_message(to: to, message: message, subject: subject)
    end

    private

    def provider
      @provider ||= case Rails.application.config.sms_provider
      when "aws_sns"
                      SmsProviders::AwsSns.new
      when "infobip"
                      SmsProviders::Infobip.new
      when "test"
                      SmsProviders::Test.new
      else
                      raise "Unsupported SMS provider: #{Rails.application.config.sms_provider}"
      end
    end
  end
end
