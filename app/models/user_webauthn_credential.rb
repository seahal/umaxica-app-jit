# frozen_string_literal: true

class UserWebauthnCredential < IdentifiersRecord
  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :nickname, presence: true
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # WebAuthn authenticator types
  enum :authenticator_type, {
    platform: 0,      # Touch ID, Face ID, Windows Hello, etc.
    roaming: 1        # YubiKey, Security keys, etc.
  }

  scope :active, -> { where(active: true) }

  def increment_sign_count!
    update!(sign_count: sign_count + 1)
  end

  def deactivate!
    update!(active: false)
  end
end
