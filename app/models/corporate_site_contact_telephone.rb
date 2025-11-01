class CorporateSiteContactTelephone < GuestsRecord
  has_many :corporate_site_contacts,
           inverse_of: :corporate_site_contact_telephone,
           dependent: :restrict_with_error

  after_commit :apply_pending_contact, on: %i[create update]

  # Backwards compatible accessor for older API usage
  def corporate_site_contact
    corporate_site_contacts.first
  end

  def corporate_site_contact=(contact)
    @pending_corporate_site_contact = contact
  end
  encrypts :telephone_number, deterministic: true
  # Bridge OTP helpers to stored verifier_* columns
  alias_attribute :otp_digest, :verifier_digest
  alias_attribute :otp_expires_at, :verifier_expires_at
  alias_attribute :otp_attempts_left, :verifier_attempts_left

  # Validations
  validates :telephone_number, presence: true,
                               format: { with: /\A\+?[\d\s\-\(\)]+\z/ }

  # Generate and store OTP
  def generate_otp!
    raw_otp = SecureRandom.random_number(100000..999999).to_s # 6-digit OTP
    self.otp_digest = Argon2::Password.create(raw_otp)
    self.otp_expires_at = 10.minutes.from_now
    self.otp_attempts_left = 3
    save!
    raw_otp # Return raw OTP only once
  end

  # Verify the OTP
  def verify_otp(raw_otp)
    return false if otp_attempts_left <= 0
    return false if otp_expires_at && Time.current >= otp_expires_at
    return false unless otp_digest

    if Argon2::Password.verify_password(raw_otp.to_s, otp_digest)
      update!(activated: true, otp_attempts_left: 0)
      true
    else
      update!(otp_attempts_left: otp_attempts_left - 1)
      false
    end
  end

  def otp_expired?
    otp_expires_at && Time.current >= otp_expires_at
  end

  def can_resend_otp?
    !activated && (otp_expired? || otp_attempts_left <= 0)
  end

  private

  def apply_pending_contact
    return unless instance_variable_defined?(:@pending_corporate_site_contact)

    contact = @pending_corporate_site_contact
    if contact
      contact.update!(corporate_site_contact_telephone: self)
    end
    remove_instance_variable(:@pending_corporate_site_contact)
  end
end
