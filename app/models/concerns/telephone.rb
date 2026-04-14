# typed: false
# frozen_string_literal: true

module Telephone
  extend ActiveSupport::Concern
  include TelephoneNormalization # FIXME: merge here!

  OTP_COOLDOWN_PERIOD = Common::OtpPolicy::SEND_COOLDOWN

  attr_accessor :confirm_policy, :confirm_using_mfa, :pass_code
  attr_writer :raw_number

  included do
    # TODO: use this new way!
    # normalizes :number, with: ->number { ? }
    before_validation :normalize_number_from_raw

    after_initialize do
      self.otp_counter = "0" if otp_counter.blank?
      self.otp_private_key = ROTP::Base32.random_base32 if otp_private_key.blank?
      self.otp_attempts_count ||= 0
    end

    encrypts :number, deterministic: true

    validate :validate_telephone_number

    validates :confirm_policy, acceptance: true,
                               unless: Proc.new { |a| a.raw_number.blank? && a.pass_code.present? }
    validates :confirm_using_mfa, acceptance: true,
                                  unless: Proc.new { |a| a.raw_number.blank? && a.pass_code.present? }
    validates :pass_code, numericality: { only_integer: true },
                          length: { is: 6 },
                          presence: true,
                          unless: Proc.new { |a| a.pass_code.blank? && a.raw_number.present? }
  end

  # OTP-related methods for telephone authentication
  # Stores OTP secret on this telephone record
  def store_otp(otp_private_key, otp_counter, expires_at)
    update!(
      otp_private_key: otp_private_key,
      otp_counter: otp_counter,
      otp_expires_at: Time.zone.at(expires_at),
      otp_attempts_count: 0,
      locked_at: "infinity", # Sentinel for unlocked: "locks at infinity" = never locked
      otp_last_sent_at: Time.current,
    )
  end

  # Retrieves OTP secret from this telephone record
  def get_otp
    return nil if otp_private_key.blank? || otp_expired? || locked?

    {
      otp_private_key: otp_private_key,
      otp_counter: Integer(otp_counter.to_s, 10),
      otp_expires_at: otp_expires_at.to_i,
    }
  end

  # Clears OTP secret after verification
  def clear_otp
    update!(
      otp_counter: "0",
      otp_expires_at: "-infinity",
      otp_attempts_count: 0,
      locked_at: "infinity", # Sentinel for unlocked: "locks at infinity" = never locked
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
    # locked_at sentinels for "not locked":
    #   -infinity  old sentinel (backward-compatible with existing rows)
    #   +infinity  new sentinel (set by store_otp / clear_otp)
    is_locked_by_time = locked_at.present? &&
      locked_at != -Float::INFINITY &&
      locked_at != Float::INFINITY
    is_locked_by_attempts = otp_attempts_count >= 3
    is_locked_by_time || is_locked_by_attempts
  end

  def otp_cooldown_active?
    return false if otp_last_sent_at.blank?
    return false if otp_last_sent_at == -Float::INFINITY

    otp_last_sent_at > OTP_COOLDOWN_PERIOD.ago
  end

  def otp_cooldown_remaining
    return 0 unless otp_cooldown_active?

    (otp_last_sent_at + OTP_COOLDOWN_PERIOD) - Time.current
  end

  def increment_attempts!

    # Atomically increment the counter to prevent race conditions with concurrent requests.
    self.class.where(id: id).update_all("otp_attempts_count = otp_attempts_count + 1, updated_at = NOW()")
    reload

    # Atomically set locked_at only when the threshold is reached and the row is not yet locked.
    # Both -infinity and +infinity are sentinel values for "not locked".
    self.class
      .where(id: id)
      .where(
        "locked_at IS NULL OR locked_at = '-infinity'::timestamp OR locked_at = 'infinity'::timestamp",
      )
      .where(otp_attempts_count: 3..)
      .update_all(locked_at: Time.current)

    reload
  end

  def raw_number
    @raw_number.presence || number
  end

  private

  def normalize_number_from_raw
    value = raw_number
    return if value.blank?

    normalized = TelephoneNormalization.normalize_to_e164(value)
    self.number = normalized if normalized.present?
  end

  def validate_telephone_number
    return if raw_number.blank? && pass_code.present?

    if raw_number.blank?
      errors.add(:number, :blank)
      return
    end

    normalized = TelephoneNormalization.normalize_to_e164(raw_number)
    unless normalized
      errors.add(:number, :invalid_e164_format)
      return
    end

    if normalized.start_with?("+0")
      errors.add(:number, :country_code_cannot_start_with_zero)
      return
    end

    unless normalized.match?(TelephoneNormalization::E164_FORMAT)
      errors.add(:number, :invalid_e164_format)
      return
    end

    digit_count = normalized.delete("+").length
    if digit_count > TelephoneNormalization::MAX_E164_DIGITS
      errors.add(:number, :exceeds_e164_length, max: TelephoneNormalization::MAX_E164_DIGITS)
    end

    return unless normalized.length > 16

    errors.add(:number, :too_long, count: 16)

  end
end
