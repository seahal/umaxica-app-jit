# frozen_string_literal: true

module EmailValidation
  extend ActiveSupport::Concern

  private

    # Validates and normalizes email address
    # Returns normalized email or nil if invalid
    def validate_and_normalize_email(email)
      return nil if email.blank?

      normalized = email.strip.downcase
      return nil unless valid_email_format?(normalized)

      normalized
    end

    # Validates email format according to RFC 5322 basic rules
    def valid_email_format?(email)
      email.match?(URI::MailTo::EMAIL_REGEXP)
    end

    # Prevents timing attacks on email lookups
    # Always spends consistent time regardless of database result
    def find_email_with_timing_protection(email)
      target_seconds = 0.05
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      result = UserIdentityEmail.find_by(address: email)

      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
      remaining = target_seconds - elapsed
      sleep(remaining) if remaining.positive?

      result
    end
end
