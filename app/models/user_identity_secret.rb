# frozen_string_literal: true

class UserIdentitySecret < IdentitiesRecord
  MAX_SECRETS_PER_USER = 10

  belongs_to :user
  belongs_to :user_identity_secret_status, optional: true

  has_secure_password algorithm: :argon2

  validate :enforce_user_secret_limit, on: :create

  private

  def enforce_user_secret_limit
    return unless user_id

    count = UserIdentitySecret.where(user_id: user_id).count
    return if count < MAX_SECRETS_PER_USER

    errors.add(:base, :too_many, message: "exceeds maximum secrets per user (#{MAX_SECRETS_PER_USER})")
  end
end
