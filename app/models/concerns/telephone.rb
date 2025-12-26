# frozen_string_literal: true

module Telephone
  extend ActiveSupport::Concern

  attr_accessor :confirm_policy, :confirm_using_mfa, :pass_code

  included do
    after_initialize do
      self.otp_counter = "0" if otp_counter.blank?
      self.otp_private_key = ROTP::Base32.random_base32 if otp_private_key.blank?
      self.otp_attempts_count ||= 0
    end

    encrypts :number, deterministic: true

    validates :number, length: { in: 3..20 },
                       format: { with: /\A\+?[\d\s\-\(\)]+\z/ },
                       uniqueness: { case_sensitive: false }
    validates :confirm_policy, acceptance: true,
                               unless: Proc.new { |a| a.number.blank? && a.pass_code.present? }
    validates :confirm_using_mfa, acceptance: true,
                                  unless: Proc.new { |a| a.number.blank? && a.pass_code.present? }
    validates :pass_code, numericality: { only_integer: true },
                          length: { is: 6 },
                          presence: true,
                          unless: Proc.new { |a| a.pass_code.blank? && a.number.present? }
  end

  # OTP-related methods for telephone authentication
  # Stores OTP secret on this telephone record
  def store_otp(otp_private_key, otp_counter, expires_at)
    update!(
      otp_private_key: otp_private_key,
      otp_counter: otp_counter,
      otp_expires_at: Time.zone.at(expires_at),
      otp_attempts_count: 0,
      locked_at: "-infinity",
    )
  end

  # Retrieves OTP secret from this telephone record
  def get_otp
    return nil if otp_private_key.blank? || otp_expired? || locked?

    {
      otp_private_key: otp_private_key,
      otp_counter: otp_counter.to_i,
      otp_expires_at: otp_expires_at.to_i,
    }
  end

  # Clears OTP secret after verification
  def clear_otp
    update!(
      otp_counter: "0",
      otp_expires_at: "-infinity",
      otp_attempts_count: 0,
      locked_at: "-infinity",
    )
  end

  # Checks if OTP has expired
  def otp_expired?
    # PostgreSQL -infinity is used as a sentinel for "never expires"
    return true if otp_expires_at.is_a?(Float) && otp_expires_at == -Float::INFINITY

    otp_expires_at.nil? || otp_expires_at <= Time.current
  end

  # Checks if OTP is still active
  def otp_active?
    !otp_expired? && !locked?
  end

  def locked?
    # PostgreSQL -infinity is used as a sentinel for "not locked"
    is_locked_by_time = locked_at.present? && locked_at != -Float::INFINITY
    is_locked_by_attempts = otp_attempts_count >= 3
    is_locked_by_time || is_locked_by_attempts
  end

  def increment_attempts!
    # Use atomic increment to prevent race condition with concurrent requests
    self.class.increment_counter(:otp_attempts_count, id, touch: true) # rubocop:disable Rails/SkipsModelValidations
    reload
    # Atomically set locked_at only when attempts reached threshold and not already locked
    # Check for both NULL and -infinity as sentinel values for "not locked"
    affected = self.class.where(id: id)
      .where("locked_at IS NULL OR locked_at = '-infinity'::timestamp")
      .where(otp_attempts_count: 3..)
      # Skip model validations intentionally: this is a guarded atomic DB update
      # to avoid race conditions when multiple processes increment simultaneously.
      # rubocop:disable Rails/SkipsModelValidations
      .update_all(locked_at: Time.current)
    # rubocop:enable Rails/SkipsModelValidations
    reload if affected.positive?
  end
end
