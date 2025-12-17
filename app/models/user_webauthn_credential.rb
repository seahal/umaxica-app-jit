# frozen_string_literal: true

class UserWebauthnCredential < IdentitiesRecord
  self.table_name = "user_passkeys"
  alias_attribute :nickname, :name
  attribute :authenticator_type, :integer

  MAX_PASSKEYS_PER_USER = UserIdentityPasskey::MAX_PASSKEYS_PER_USER

  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :nickname, presence: true
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :enforce_user_passkey_limit, on: :create

  # WebAuthn authenticator types
  enum :authenticator_type, {
    platform: 0, # Touch ID, Face ID, Windows Hello, etc.
    roaming: 1 # YubiKey, Security keys, etc.
  }

  def increment_sign_count!
    update!(sign_count: sign_count + 1)
  end

  private

  def enforce_user_passkey_limit
    return unless user_id

    count = self.class.where(user_id: user_id).count
    return if count < MAX_PASSKEYS_PER_USER

    errors.add(:base, :too_many, message: "exceeds maximum passkeys per user (#{MAX_PASSKEYS_PER_USER})")
  end
end
