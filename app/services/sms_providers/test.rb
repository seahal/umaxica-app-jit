# frozen_string_literal: true

module SmsProviders
  class Test < Base
    def send_message(to:, message:, subject: nil)
      validate_params(to: to, message: message, subject: subject)

      Rails.logger.info "[SMS Test Provider] Sending SMS to #{to}: #{message}"

      # テスト環境や開発環境で実際にSMSを送信せずにログに記録
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
