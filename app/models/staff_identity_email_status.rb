class StaffIdentityEmailStatus < IdentitiesRecord
  include UppercaseId

  has_many :staff_identity_emails, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
