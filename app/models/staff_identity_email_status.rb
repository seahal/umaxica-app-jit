# frozen_string_literal: true

class StaffIdentityEmailStatus < IdentitiesRecord
  include UppercaseIdValidation

  has_many :staff_identity_emails, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
