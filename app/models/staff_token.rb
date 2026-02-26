# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_tokens
# Database name: token
#
#  id                       :bigint           not null, primary key
#  compromised_at           :datetime
#  deletable_at             :datetime         default(Infinity), not null
#  expired_at               :datetime
#  last_step_up_at          :datetime
#  last_step_up_scope       :string
#  last_used_at             :datetime
#  refresh_expires_at       :datetime         not null
#  refresh_token_digest     :binary
#  refresh_token_generation :integer          default(0), not null
#  revoked_at               :datetime
#  rotated_at               :datetime
#  status                   :string(20)       default("active"), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  device_id                :string           default(""), not null
#  public_id                :string(21)       default(""), not null
#  refresh_token_family_id  :string
#  staff_id                 :bigint           not null
#  staff_token_kind_id      :bigint           default(1), not null
#  staff_token_status_id    :bigint           default(0), not null
#
# Indexes
#
#  index_staff_tokens_on_compromised_at                (compromised_at)
#  index_staff_tokens_on_deletable_at                  (deletable_at)
#  index_staff_tokens_on_device_id                     (device_id)
#  index_staff_tokens_on_expired_at                    (expired_at)
#  index_staff_tokens_on_public_id                     (public_id) UNIQUE
#  index_staff_tokens_on_refresh_expires_at            (refresh_expires_at)
#  index_staff_tokens_on_refresh_token_digest          (refresh_token_digest) UNIQUE
#  index_staff_tokens_on_refresh_token_family_id       (refresh_token_family_id)
#  index_staff_tokens_on_revoked_at                    (revoked_at)
#  index_staff_tokens_on_staff_id_and_last_step_up_at  (staff_id,last_step_up_at)
#  index_staff_tokens_on_staff_token_kind_id           (staff_token_kind_id)
#  index_staff_tokens_on_staff_token_status_id         (staff_token_status_id)
#  index_staff_tokens_on_status                        (status)
#
# Foreign Keys
#
#  fk_staff_tokens_on_staff_token_kind_id    (staff_token_kind_id => staff_token_kinds.id)
#  fk_staff_tokens_on_staff_token_status_id  (staff_token_status_id => staff_token_statuses.id)
#

# Refresh tokens are persisted as digests only.
# The public_id is used as the session identifier (sid).
class StaffToken < TokenRecord
  include ::PublicId
  include ::RefreshTokenable
  include ::SignedSessionReference
  include ::TokenDeletableSync
  include ::TokenStatusManagement

  MAX_SESSIONS_PER_STAFF = 2
  MAX_TOTAL_SESSIONS_PER_STAFF = 3

  belongs_to :staff
  belongs_to :staff_token_status
  belongs_to :staff_token_kind, optional: true
  has_many :staff_verifications, dependent: :delete_all, inverse_of: :staff_token
  attribute :staff_token_status_id, default: StaffTokenStatus::NOTHING
  attribute :staff_token_kind_id, default: StaffTokenKind::BROWSER_WEB

  validates :public_id, uniqueness: true, length: { maximum: 21 }
  validates :refresh_expires_at, presence: true

  validate :enforce_concurrent_session_limit, on: :create

  # This is a model-level validation to provide a friendly error message to the user.
  # The primary enforcement of the session limit is done by a database trigger,
  # which is more reliable and avoids race conditions.
  def enforce_concurrent_session_limit
    return unless staff_id

    count = self.class.not_revoked.where(staff_id: staff_id, rotated_at: nil).count
    return if count < MAX_TOTAL_SESSIONS_PER_STAFF

    errors.add(
      :base, :too_many,
      message: "exceeds maximum concurrent sessions per staff (#{MAX_TOTAL_SESSIONS_PER_STAFF})",
    )
  end
end
