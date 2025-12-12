# frozen_string_literal: true

class UserIdentityGoogleAuthStatus < IdentitiesRecord
  has_many :user_identity_google_auths, dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
