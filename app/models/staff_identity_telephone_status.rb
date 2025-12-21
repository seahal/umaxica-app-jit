# frozen_string_literal: true

class StaffIdentityTelephoneStatus < IdentitiesRecord
  include UppercaseId

  has_many :staff_identity_telephones, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
