# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_tokens
# Database name: token
#
#  id                       :bigint           not null, primary key
#  compromised_at           :datetime
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
#  public_id                :string(21)       default(""), not null
#  refresh_token_family_id  :string
#  staff_id                 :bigint           not null
#  staff_token_kind_id      :bigint           default(1), not null
#  staff_token_status_id    :bigint           default(2), not null
#
# Indexes
#
#  index_staff_tokens_on_compromised_at                (compromised_at)
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

  # Maximum active sessions per staff
  MAX_SESSIONS_PER_STAFF = 2

  # Total maximum sessions (active + restricted)
  MAX_TOTAL_SESSIONS_PER_STAFF = 3
  RESTRICTED_TTL = 15.minutes

  # Status values for session state management
  STATUS_ACTIVE = "active"
  STATUS_RESTRICTED = "restricted"
  STATUS_REVOKED = "revoked"

  VALID_STATUSES = [STATUS_ACTIVE, STATUS_RESTRICTED, STATUS_REVOKED].freeze

  belongs_to :staff
  belongs_to :staff_token_status
  belongs_to :staff_token_kind, optional: true
  attribute :staff_token_status_id, default: StaffTokenStatus::NEYO
  attribute :staff_token_kind_id, default: StaffTokenKind::BROWSER_WEB
  attribute :status, default: STATUS_ACTIVE

  validates :public_id, uniqueness: true, length: { maximum: 21 }
  validates :refresh_expires_at, presence: true
  validates :status, inclusion: { in: VALID_STATUSES }, length: { maximum: 20 }

  validate :enforce_concurrent_session_limit, on: :create

  # Scopes for session status
  scope :active_status, -> { where(status: STATUS_ACTIVE, revoked_at: nil) }
  scope :restricted_status, -> { where(status: STATUS_RESTRICTED, revoked_at: nil) }
  scope :not_revoked, -> { where(revoked_at: nil) }

  # Check if this session is restricted
  def restricted?
    status == STATUS_RESTRICTED
  end

  # Check if this session is active
  def active_status?
    status == STATUS_ACTIVE && revoked_at.nil?
  end

  # Mark session as restricted
  def mark_restricted!
    update!(status: STATUS_RESTRICTED)
  end

  # Promote restricted session to active
  def promote_to_active!
    update!(status: STATUS_ACTIVE)
  end

  # Revoke the session
  def revoke!
    update!(revoked_at: Time.current, status: STATUS_REVOKED)
  end

  # Generate a signed reference for safe external exposure
  def signed_ref
    Rails.application.message_verifier(:session_ref).generate(
      { id: id, pid: public_id },
      expires_in: 1.hour,
    )
  end

  # Find token by signed reference (returns nil if invalid/expired)
  def self.find_from_signed_ref(signed_ref)
    return nil if signed_ref.blank?

    data = Rails.application.message_verifier(:session_ref).verify(signed_ref)
    find_by(id: data[:id], public_id: data[:pid])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  private

  # This is a model-level validation to provide a friendly error message to the user.
  # The primary enforcement of the session limit is done by a database trigger,
  # which is more reliable and avoids race conditions.
  def enforce_concurrent_session_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_TOTAL_SESSIONS_PER_STAFF

    errors.add(
      :base, :too_many,
      message: "exceeds maximum concurrent sessions per staff (#{MAX_TOTAL_SESSIONS_PER_STAFF})",
    )
  end
end
