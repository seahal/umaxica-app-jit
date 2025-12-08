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
    start_time = Time.now.to_f
    result = UserIdentityEmail.find_by(address: email)

    # Ensure consistent timing (aim for ~50ms to avoid noticeable delay)
    target_duration_ms = 50
    elapsed_ms = (Time.now.to_f - start_time) * 1000
    sleep((target_duration_ms - elapsed_ms) / 1000.0) if elapsed_ms < target_duration_ms

    result
  end
end
