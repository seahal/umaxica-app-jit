class UserIdentitySecretStatus < IdentitiesRecord
  has_many :user_identity_secrets, dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
