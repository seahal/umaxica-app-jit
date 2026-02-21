# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_verifications
# Database name: token
#
#  id             :bigint           not null, primary key
#  expires_at     :datetime         not null
#  last_used_at   :datetime
#  revoked_at     :datetime
#  token_digest   :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  staff_token_id :bigint           not null
#
# Indexes
#
#  index_staff_verifications_on_expires_at      (expires_at)
#  index_staff_verifications_on_staff_token_id  (staff_token_id)
#  index_staff_verifications_on_token_digest    (token_digest) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (staff_token_id => staff_tokens.id) ON DELETE => cascade
#
class StaffVerification < TokenRecord
  include RefreshTokenShared

  COOKIE_NAME = "__Host-jit_step_up_org"
  TTL = 15.minutes

  belongs_to :staff_token, inverse_of: :staff_verifications

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  def active?
    revoked_at.nil? && expires_at.present? && expires_at > Time.current
  end

  def self.cookie_name
    COOKIE_NAME
  end

  def self.digest_token(raw_token)
    digest_refresh_token(raw_token.to_s).unpack1("H*")
  end

  def self.issue_for_token!(token:, expires_at: TTL.from_now)
    now = Time.current
    raw_token = SecureRandom.urlsafe_base64(32)
    digest = digest_token(raw_token)

    verification =
      transaction do
        # rubocop:disable Rails/SkipsModelValidations
        where(staff_token_id: token.id).active.update_all(revoked_at: now, updated_at: now)
        # rubocop:enable Rails/SkipsModelValidations
        create!(
          staff_token: token,
          token_digest: digest,
          expires_at: expires_at,
          last_used_at: now,
        )
      end

    [verification, raw_token]
  end
end
