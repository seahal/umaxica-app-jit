# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_telephones
#
#  id                     :string           not null, primary key
#  org_contact_id         :uuid             not null
#  telephone_number       :string(1000)     default(""), not null
#  activated              :boolean          default(FALSE), not null
#  deletable              :boolean          default(FALSE), not null
#  remaining_views        :integer          default(0), not null
#  verifier_digest        :string(255)      default(""), not null
#  verifier_expires_at    :timestamptz      default("-infinity"), not null
#  verifier_attempts_left :integer          default(0), not null
#  expires_at             :timestamptz      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_org_contact_telephones_on_expires_at           (expires_at)
#  index_org_contact_telephones_on_org_contact_id       (org_contact_id)
#  index_org_contact_telephones_on_telephone_number     (telephone_number)
#  index_org_contact_telephones_on_verifier_expires_at  (verifier_expires_at)
#

class OrgContactTelephone < GuestRecord
  belongs_to :org_contact, inverse_of: :org_contact_telephones

  before_create :generate_id
  encrypts :telephone_number, deterministic: true
  # Bridge OTP helpers to stored verifier_* columns
  alias_attribute :otp_digest, :verifier_digest
  alias_attribute :otp_expires_at, :verifier_expires_at
  alias_attribute :otp_attempts_left, :verifier_attempts_left

  # Validations
  validates :telephone_number, presence: true, length: { maximum: 1000 },
                               format: { with: /\A\+?[\d\s\-\(\)]+\z/ }
  validates :verifier_digest, length: { maximum: 255 }

  # Generate and store OTP
  def generate_otp!
    raw_otp = SecureRandom.random_number(100_000..999_999).to_s # 6-digit OTP
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

  def generate_id
    self.id ||= Nanoid.generate(size: 21)
  end
end
