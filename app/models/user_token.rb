# frozen_string_literal: true

class UserToken < TokensRecord
  MAX_SESSIONS_PER_USER = 2

  belongs_to :user
  belongs_to :user_token_status

  validate :enforce_concurrent_session_limit, on: :create

  private

  def enforce_concurrent_session_limit
    return unless user_id

    count = self.class.where(user_id: user_id).count
    return if count < MAX_SESSIONS_PER_USER

    errors.add(:base, :too_many, message: "exceeds maximum concurrent sessions per user (#{MAX_SESSIONS_PER_USER})")
  end
end
