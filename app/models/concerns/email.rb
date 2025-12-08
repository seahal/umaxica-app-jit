module Email
  extend ActiveSupport::Concern

  attr_accessor :confirm_policy, :pass_code

  included do
    belongs_to :user, optional: true
    belongs_to :staff, optional: true

    before_save { self.address&.downcase! }

    encrypts :address, downcase: true, deterministic: true

    validates :address, format: { with: URI::MailTo::EMAIL_REGEXP },
              presence: true,
              uniqueness: { case_sensitive: false },
              unless: Proc.new { |a| a.address.nil? && !a.pass_code.nil? }
    validates :confirm_policy, acceptance: true,
              unless: Proc.new { |a| a.address.nil? && !a.pass_code.nil? }
    validates :pass_code, numericality: { only_integer: true },
              length: { is: 6 },
              presence: true,
              unless: Proc.new { |a| a.pass_code.nil? && !a.address.nil? }
  end

  # OTP-related methods for email authentication
  # Stores OTP secret on this email record
  def store_otp(otp_private_key, otp_counter, expires_at)
    update!(
      otp_private_key: otp_private_key,
      otp_counter: otp_counter,
      otp_expires_at: Time.zone.at(expires_at)
    )
  end

  # Retrieves OTP secret from this email record
  def get_otp
    return nil if otp_private_key.blank? || otp_expired?

    {
      otp_private_key: otp_private_key,
      otp_counter: otp_counter.to_i,
      otp_expires_at: otp_expires_at.to_i
    }
  end

  # Clears OTP secret after verification
  def clear_otp
    update!(
      otp_private_key: nil,
      otp_counter: nil,
      otp_expires_at: nil
    )
  end

  # Checks if OTP has expired
  def otp_expired?
    otp_expires_at.nil? || otp_expires_at <= Time.current
  end

  # Checks if OTP is still active
  def otp_active?
    !otp_expired?
  end
end
