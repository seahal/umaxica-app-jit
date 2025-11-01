class CorporateSiteContactEmail < GuestsRecord
  has_many :corporate_site_contacts,
           inverse_of: :corporate_site_contact_email,
           dependent: :restrict_with_error

  after_commit :apply_pending_contact, on: %i[create update]

  # Backwards compatible accessors for legacy API usage in fixtures/tests
  def corporate_site_contact
    corporate_site_contacts.first
  end

  def corporate_site_contact=(contact)
    @pending_corporate_site_contact = contact
  end

  before_save { self.email_address&.downcase! }
  encrypts :email_address, downcase: true, deterministic: true

  # Validations
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Generate and store email verification code
  def generate_verifier!
    raw_code = SecureRandom.random_number(100000..999999).to_s # 6-digit code
    self.verifier_digest = Argon2::Password.create(raw_code)
    self.verifier_expires_at = 15.minutes.from_now
    self.verifier_attempts_left = 3
    save!
    raw_code # Return raw code only once
  end

  # Verify the code
  def verify_code(raw_code)
    return false if verifier_attempts_left <= 0
    return false if verifier_expires_at && Time.current >= verifier_expires_at
    return false unless verifier_digest

    if Argon2::Password.verify_password(raw_code.to_s, verifier_digest)
      update!(activated: true, verifier_attempts_left: 0)
      true
    else
      update!(verifier_attempts_left: verifier_attempts_left - 1)
      false
    end
  end

  def verifier_expired?
    verifier_expires_at && Time.current >= verifier_expires_at
  end

  def can_resend_verifier?
    !activated && (verifier_expired? || verifier_attempts_left <= 0)
  end

  private

  def apply_pending_contact
    return unless instance_variable_defined?(:@pending_corporate_site_contact)

    contact = @pending_corporate_site_contact
    if contact
      contact.update!(corporate_site_contact_email: self)
    end
    remove_instance_variable(:@pending_corporate_site_contact)
  end
end
