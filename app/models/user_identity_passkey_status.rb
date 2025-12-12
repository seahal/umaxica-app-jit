# frozen_string_literal: true

class UserIdentityPasskeyStatus < IdentitiesRecord
  has_many :user_identity_passkeys, dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true

  # Status constants
  ACTIVE = "ACTIVE"
  DISABLED = "DISABLED"
  DELETED = "DELETED"
end
