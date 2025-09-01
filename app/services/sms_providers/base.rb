# frozen_string_literal: true

module SmsProviders
  class Base
    def send_message(to:, message:, subject: nil)
      raise NotImplementedError, "#{self.class} must implement #send_message"
    end

    protected

    def validate_params(to:, message:, subject: nil)
      raise ArgumentError, "Phone number is required" if to.blank?
      raise ArgumentError, "Message is required" if message.blank?
    end
  end
end
