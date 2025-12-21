# frozen_string_literal: true

class UserIdentitySecretStatus < IdentitiesRecord
  include UppercaseId

  has_many :user_identity_secrets, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
