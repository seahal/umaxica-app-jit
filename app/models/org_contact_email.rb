# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_emails
# Database name: guest
#
#  id                     :bigint           not null, primary key
#  activated              :boolean          default(FALSE), not null
#  email_address          :string(1000)     default(""), not null
#  token_digest           :string(255)
#  token_expires_at       :timestamptz
#  token_viewed           :boolean          default(FALSE), not null
#  verifier_attempts_left :integer          default(3), not null
#  verifier_digest        :string(255)
#  verifier_expires_at    :timestamptz
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  org_contact_id         :bigint           not null
#
# Indexes
#
#  index_org_contact_emails_on_email_address   (email_address)
#  index_org_contact_emails_on_org_contact_id  (org_contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_contact_id => org_contacts.id)
#

class OrgContactEmail < GuestRecord
  belongs_to :org_contact, inverse_of: :org_contact_emails

  # Validations
  validates :email_address, presence: true, length: { maximum: 1000 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token_digest, length: { maximum: 255 }
  validates :verifier_digest, length: { maximum: 255 }
  before_save { self.email_address&.downcase! }
  encrypts :email_address, downcase: true, deterministic: true

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
end
