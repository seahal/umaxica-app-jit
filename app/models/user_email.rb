# frozen_string_literal: true

# == Schema Information
#
# Table name: user_emails
# Database name: principal
#
#  id                            :bigint           not null, primary key
#  address                       :string           default(""), not null
#  locked_at                     :datetime         default(-Infinity), not null
#  otp_attempts_count            :integer          default(0), not null
#  otp_counter                   :text             default(""), not null
#  otp_expires_at                :datetime         default(-Infinity), not null
#  otp_last_sent_at              :datetime         default(-Infinity), not null
#  otp_private_key               :string           default(""), not null
#  verification_token_digest     :binary
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  public_id                     :string(21)       not null
#  user_id                       :bigint           not null
#  user_identity_email_status_id :bigint           default(1), not null
#
# Indexes
#
#  index_user_emails_on_otp_last_sent_at               (otp_last_sent_at)
#  index_user_emails_on_public_id                      (public_id) UNIQUE
#  index_user_emails_on_user_id                        (user_id)
#  index_user_emails_on_user_identity_email_status_id  (user_identity_email_status_id)
#  index_user_identity_emails_on_lower_address         (lower((address)::text)) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (user_identity_email_status_id => user_email_statuses.id)
#

class UserEmail < PrincipalRecord
  alias_attribute :user_email_status_id, :user_identity_email_status_id
  include PublicId
  include Email

  include Turnstile

  MAX_EMAILS_PER_USER = 4
  attribute :user_identity_email_status_id, default: UserEmailStatus::UNVERIFIED
  belongs_to :user_email_status,
             optional: true,
             inverse_of: :user_emails,
             foreign_key: :user_identity_email_status_id
  belongs_to :user, optional: false, inverse_of: :user_emails
  validates :address, presence: true, length: { maximum: 255 }
  validates :otp_attempts_count, presence: true, numericality: { only_integer: true }
  validates :otp_counter, presence: true
  validates :otp_private_key, presence: true, length: { maximum: 255 }
  validates :user_identity_email_status_id, numericality: { only_integer: true }
  validate :enforce_user_email_limit, on: :create

  def to_param
    public_id
  end

  after_initialize do
    self.address ||= ""
  end

  encrypts :address, deterministic: true

  # Generates a new verification token and saves its digest
  # Returns the raw token
  def generate_verification_token
    raw_token = SecureRandom.urlsafe_base64(32)
    self.verification_token_digest = Digest::SHA256.hexdigest(raw_token)
    save!
    raw_token
  end

  def verify_verification_token(raw_token)
    return false if raw_token.blank? || verification_token_digest.blank?

    # Secure comparison of digests
    ActiveSupport::SecurityUtils.secure_compare(
      verification_token_digest,
      Digest::SHA256.hexdigest(raw_token),
    )
  end

  private

  def enforce_user_email_limit
    return unless user_id

    count = self.class.where(user_id: user_id).count
    return if count < MAX_EMAILS_PER_USER

    errors.add(:base, :too_many, message: "exceeds maximum emails per user (#{MAX_EMAILS_PER_USER})")
  end
end
