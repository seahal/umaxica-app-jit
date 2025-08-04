# frozen_string_literal: true

module SmsProviders
  class Test < Base
    def send_message(to:, message:, subject: nil)
      validate_params(to: to, message: message, subject: subject)

      Rails.logger.info "[SMS Test Provider] Sending SMS to #{to}: #{message}"

      # Log SMS in test and development environments without actually sending
      {
        to: to,
        message: message,
        subject: subject,
        sent_at: Time.current,
        provider: "test"
      }
    end
  end
end
