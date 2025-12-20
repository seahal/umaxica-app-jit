# frozen_string_literal: true

class StaffIdentitySecretStatus < IdentitiesRecord
  include UppercaseId

  has_many :staff_identity_secrets, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
