class ComContactEmail < GuestsRecord
  belongs_to :com_contact

  before_create :generate_id
  before_save { self.email_address&.downcase! }
  encrypts :email_address, downcase: true, deterministic: true

  # Validations
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Encryptions
  encrypts :hotp_secret

  # Generate and store email verification code
  # TODO: Rewrite this code to otp generator
  def generate_verifier!
    raw_code = SecureRandom.random_number(100000..999999).to_s # 6-digit code
    self.verifier_digest = Argon2::Password.create(raw_code)
    self.verifier_expires_at = 15.minutes.from_now
    self.verifier_attempts_left = 3
    save!
    raw_code # Return raw code only once
  end

  # Verify the code
  # TODO: Rewrite this code to otp verifier
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

  # TODO: Rewrite this code to otp verifier
  def verifier_expired?
    verifier_expires_at && Time.current >= verifier_expires_at
  end

  # TODO: Rewrite this code to otp verifier
  def can_resend_verifier?
    !activated && (verifier_expired? || verifier_attempts_left <= 0)
  end

  # Generate and store HOTP secret, counter, and code
  def generate_hotp!
    secret = ROTP::Base32.random
    hotp = ROTP::HOTP.new(secret)
    counter = SecureRandom.random_number(1_000_000)
    code = hotp.at(counter)

    self.hotp_secret = secret
    self.hotp_counter = counter
    self.verifier_expires_at = 15.minutes.from_now
    self.verifier_attempts_left = 3
    save!

    code # Return code only once
  end

  # Verify HOTP code
  def verify_hotp_code(raw_code)
    return false if verifier_attempts_left <= 0
    return false if verifier_expires_at && Time.current >= verifier_expires_at
    return false unless hotp_secret && hotp_counter

    hotp = ROTP::HOTP.new(hotp_secret)
    if hotp.verify(raw_code.to_s, hotp_counter) == hotp_counter
      update!(activated: true, verifier_attempts_left: 0)
      true
    else
      update!(verifier_attempts_left: verifier_attempts_left - 1)
      false
    end
  end

  private

  # TODO: rewrite this code to be concerned ... how about public_id.rb ?
  #     : rename to generate_public_id
  def generate_id
    self.id ||= Nanoid.generate(size: 21)
  end
end
