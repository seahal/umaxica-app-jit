# == Schema Information
#
# Table name: org_contact_emails
#
#  id                     :string           not null, primary key
#  activated              :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  deletable              :boolean          default(FALSE), not null
#  email_address          :string(1000)     default(""), not null
#  expires_at             :timestamptz      not null
#  org_contact_id         :uuid             not null
#  remaining_views        :integer          default(10), not null
#  token_digest           :string(255)      default(""), not null
#  token_expires_at       :timestamptz      default("-infinity"), not null
#  token_viewed           :boolean          default(FALSE), not null
#  updated_at             :datetime         not null
#  verifier_attempts_left :integer          default(3), not null
#  verifier_digest        :string(255)      default(""), not null
#  verifier_expires_at    :timestamptz      default("-infinity"), not null
#
# Indexes
#
#  index_org_contact_emails_on_email_address        (email_address)
#  index_org_contact_emails_on_expires_at           (expires_at)
#  index_org_contact_emails_on_org_contact_id       (org_contact_id)
#  index_org_contact_emails_on_verifier_expires_at  (verifier_expires_at)
#

class OrgContactEmail < GuestsRecord
  belongs_to :org_contact

  before_create :generate_id
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

    def generate_id
      self.id ||= Nanoid.generate(size: 21)
    end
end
