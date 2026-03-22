# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_emails
# Database name: guest
#
#  id                     :bigint           not null, primary key
#  activated              :boolean          default(FALSE), not null
#  deletable              :boolean          default(FALSE), not null
#  email_address          :string(1000)     default(""), not null
#  expires_at             :datetime         not null
#  hotp_counter           :integer
#  hotp_secret            :string
#  remaining_views        :integer          default(10), not null
#  token_digest           :string(255)
#  token_expires_at       :datetime
#  token_viewed           :boolean          default(FALSE), not null
#  verifier_attempts_left :integer          default(3), not null
#  verifier_digest        :string(255)
#  verifier_expires_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  com_contact_id         :bigint           default(0), not null
#
# Indexes
#
#  index_com_contact_emails_on_com_contact_id_unique  (com_contact_id) UNIQUE
#  index_com_contact_emails_on_email_address          (email_address)
#
# Foreign Keys
#
#  fk_rails_...  (com_contact_id => com_contacts.id)
#

class ComContactEmail < GuestRecord
  belongs_to :com_contact, inverse_of: :com_contact_email

  # Validations
  validates :email_address, presence: true, length: { maximum: 1000 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token_digest, length: { maximum: 255 }
  validates :verifier_digest, length: { maximum: 255 }
  validates :com_contact_id, uniqueness: true

  before_save { email_address&.downcase! }
  encrypts :email_address, downcase: true, deterministic: true

  # Encryptions
  encrypts :hotp_secret

  # Generate and store email verification code
  def generate_verifier!
    raw_code = SecureRandom.random_number(100_000..999_999).to_s # 6-digit code
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

    # return false unless verifier_digest # Handled by Argon2 check

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
end
