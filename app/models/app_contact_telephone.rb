# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_telephones
# Database name: guest
#
#  id                     :bigint           not null, primary key
#  activated              :boolean          default(FALSE), not null
#  telephone_number       :string(1000)     default(""), not null
#  verifier_attempts_left :integer          default(3), not null
#  verifier_digest        :string(255)
#  verifier_expires_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  app_contact_id         :bigint           default(0), not null
#
# Indexes
#
#  index_app_contact_telephones_on_app_contact_id    (app_contact_id)
#  index_app_contact_telephones_on_telephone_number  (telephone_number)
#
# Foreign Keys
#
#  fk_rails_...  (app_contact_id => app_contacts.id)
#
class AppContactTelephone < GuestRecord
  include TelephoneNormalization

  belongs_to :app_contact, inverse_of: :app_contact_telephones

  normalize_telephone_field :telephone_number

  validates :verifier_digest, length: { maximum: 255 }

  encrypts :telephone_number, deterministic: true
  alias_attribute :otp_digest, :verifier_digest
  alias_attribute :otp_expires_at, :verifier_expires_at
  alias_attribute :otp_attempts_left, :verifier_attempts_left

  def generate_otp!
    raw_otp = SecureRandom.random_number(100_000..999_999).to_s
    self.otp_digest = Argon2::Password.create(raw_otp)
    self.otp_expires_at = 10.minutes.from_now
    self.otp_attempts_left = 3
    save!
    raw_otp
  end

  def verify_otp(raw_otp)
    return false if otp_attempts_left <= 0
    return false if otp_expires_at && Time.current >= otp_expires_at

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
    !activated && (otp_digest.nil? || otp_expired? || otp_attempts_left <= 0)
  end
end
