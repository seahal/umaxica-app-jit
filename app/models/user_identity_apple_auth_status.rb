# frozen_string_literal: true

class UserIdentityAppleAuthStatus < IdentitiesRecord
  has_many :user_identity_apple_auths, dependent: :restrict_with_error

  before_validation { self.id = id&.upcase }
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[A-Z0-9_]+\z/ }

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
