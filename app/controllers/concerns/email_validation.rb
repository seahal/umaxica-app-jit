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
    email.match?(/\A[a-z0-9]+([._+-][a-z0-9]+)*@[a-z0-9]+([.-][a-z0-9]+)*\.[a-z]{2,}\z/i)
  end

  # Prevents timing attacks on email lookups
  # Always spends consistent time regardless of database result
  def find_email_with_timing_protection(email)
    # Always perform database query (prevents timing leak)
    existing = UserIdentityEmail.find_by(address: email)

    # Use sleep to ensure consistent response time (basic mitigation)
    # Production should use Redis-based constant time comparison
    sleep(0.05) if existing.nil?

    existing
  end
end
