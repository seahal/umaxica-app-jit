# frozen_string_literal: true

class UserIdentityTelephoneStatus < IdentitiesRecord
  include UppercaseIdValidation

  has_many :user_identity_telephones, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
