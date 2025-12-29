# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_tokens
#
#  id                    :uuid             not null, primary key
#  staff_id              :uuid             not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  staff_token_status_id :string           default("NEYO"), not null
#  refresh_token_digest  :binary
#  public_id             :string(21)       default(""), not null
#  refresh_expires_at    :datetime         not null
#  revoked_at            :datetime
#  rotated_at            :datetime
#  last_used_at          :datetime
#
# Indexes
#
#  index_staff_tokens_on_public_id              (public_id) UNIQUE
#  index_staff_tokens_on_refresh_expires_at     (refresh_expires_at)
#  index_staff_tokens_on_refresh_token_digest   (refresh_token_digest) UNIQUE
#  index_staff_tokens_on_revoked_at             (revoked_at)
#  index_staff_tokens_on_staff_id               (staff_id)
#  index_staff_tokens_on_staff_token_status_id  (staff_token_status_id)
#

# Refresh tokens are persisted as digests only.
# The public_id is used as the session identifier (sid).
class StaffToken < TokensRecord
  self.implicit_order_column = :created_at
  include ::PublicId
  include ::RefreshTokenable

  MAX_SESSIONS_PER_STAFF = 2

  belongs_to :staff
  belongs_to :staff_token_status
  attribute :staff_token_status_id, default: "NEYO"

  validates :public_id, uniqueness: true, length: { maximum: 21 }
  validates :refresh_expires_at, presence: true

  validate :enforce_concurrent_session_limit, on: :create

  private

  # This is a model-level validation to provide a friendly error message to the user.
  # The primary enforcement of the session limit is done by a database trigger,
  # which is more reliable and avoids race conditions.
  def enforce_concurrent_session_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_SESSIONS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum concurrent sessions per staff (#{MAX_SESSIONS_PER_STAFF})")
  end
end
