# frozen_string_literal: true

class UserIdentityAppleAuthStatus < IdentitiesRecord
  has_many :user_identity_apple_auths, dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
