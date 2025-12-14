# frozen_string_literal: true

class UserIdentityGoogleAuthStatus < IdentitiesRecord
  include UppercaseIdValidation

  has_many :user_identity_google_auths, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
