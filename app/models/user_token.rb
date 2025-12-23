# Refresh tokens are persisted as digests only.
# The public_id is used as the session identifier (sid).
class UserToken < TokensRecord
  include ::PublicId
  include ::RefreshTokenable

  MAX_SESSIONS_PER_USER = 2

  belongs_to :user
  belongs_to :user_token_status

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
