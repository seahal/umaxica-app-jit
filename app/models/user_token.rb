# frozen_string_literal: true

# == Schema Information
#
# Table name: user_tokens
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
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  public_id                :string(21)       default(""), not null
#  refresh_token_family_id  :string
#  user_id                  :bigint           not null
#  user_token_kind_id       :bigint           default(11), not null
#  user_token_status_id     :bigint           default(0), not null
#
# Indexes
#
#  index_user_tokens_on_compromised_at               (compromised_at)
#  index_user_tokens_on_public_id                    (public_id) UNIQUE
#  index_user_tokens_on_refresh_expires_at           (refresh_expires_at)
#  index_user_tokens_on_refresh_token_digest         (refresh_token_digest) UNIQUE
#  index_user_tokens_on_refresh_token_family_id      (refresh_token_family_id)
#  index_user_tokens_on_revoked_at                   (revoked_at)
#  index_user_tokens_on_user_id_and_last_step_up_at  (user_id,last_step_up_at)
#  index_user_tokens_on_user_token_kind_id           (user_token_kind_id)
#  index_user_tokens_on_user_token_status_id         (user_token_status_id)
#
# Foreign Keys
#
#  fk_user_tokens_on_user_token_kind_id    (user_token_kind_id => user_token_kinds.id)
#  fk_user_tokens_on_user_token_status_id  (user_token_status_id => user_token_statuses.id)
#

# Refresh tokens are persisted as digests only.
# The public_id is used as the session identifier (sid).
class UserToken < TokenRecord
  include ::PublicId
  include ::RefreshTokenable

  MAX_SESSIONS_PER_USER = 2

  belongs_to :user, inverse_of: :user_tokens
  belongs_to :user_token_status
  belongs_to :user_token_kind, optional: true
  attribute :user_token_status_id, default: UserTokenStatus::NEYO
  attribute :user_token_kind_id, default: UserTokenKind::BROWSER_WEB

  validates :public_id, uniqueness: true, length: { maximum: 21 }
  validates :refresh_expires_at, presence: true

  validate :enforce_concurrent_session_limit, on: :create

  private

  # This is a model-level validation to provide a friendly error message to the user.
  # The primary enforcement of the session limit is done by a database trigger,
  # which is more reliable and avoids race conditions.
  def enforce_concurrent_session_limit
    return unless user_id

    count = self.class.where(user_id: user_id).count
    return if count < MAX_SESSIONS_PER_USER

    errors.add(:base, :too_many, message: "exceeds maximum concurrent sessions per user (#{MAX_SESSIONS_PER_USER})")
  end
end
