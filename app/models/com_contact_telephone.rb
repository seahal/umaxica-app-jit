# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_telephones
# Database name: guest
#
#  id                     :bigint           not null, primary key
#  activated              :boolean          default(FALSE), not null
#  deletable              :boolean          default(FALSE), not null
#  expires_at             :datetime         not null
#  hotp_counter           :integer
#  hotp_secret            :string
#  remaining_views        :integer          default(10), not null
#  telephone_number       :string(1000)     default(""), not null
#  verifier_attempts_left :integer          default(3), not null
#  verifier_digest        :string(255)
#  verifier_expires_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  com_contact_id         :bigint           default(0), not null
#
# Indexes
#
#  index_com_contact_telephones_on_com_contact_id_unique  (com_contact_id) UNIQUE
#  index_com_contact_telephones_on_telephone_number       (telephone_number)
#
# Foreign Keys
#
#  fk_rails_...  (com_contact_id => com_contacts.id)
#

class ComContactTelephone < GuestRecord
  include TelephoneNormalization

  belongs_to :com_contact, inverse_of: :com_contact_telephone

  # E.164 normalization and validation
  normalize_telephone_field :telephone_number

  validates :verifier_digest, length: { maximum: 255 }
  validates :com_contact_id, uniqueness: true

  encrypts :telephone_number, deterministic: true
  encrypts :hotp_secret

  # Bridge OTP helpers to stored verifier_* columns
  alias_attribute :otp_digest, :verifier_digest
  alias_attribute :otp_expires_at, :verifier_expires_at
  alias_attribute :otp_attempts_left, :verifier_attempts_left

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

    # return false unless otp_digest # Handled by Argon2 check

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

  # Generate and store HOTP secret, counter (odd number), and code
  def generate_hotp!
    secret = ROTP::Base32.random
    hotp = ROTP::HOTP.new(secret)
    # Generate odd counter (multiply by 2 and add 1 to ensure odd number)
    counter = (rand(1...1_000_000) * 2) + 1
    code = hotp.at(counter)

    self.hotp_secret = secret
    self.hotp_counter = counter
    self.verifier_expires_at = 10.minutes.from_now
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
