# frozen_string_literal: true

class UserIdentityGoogleAuthStatus < IdentitiesRecord
  include UppercaseId

  has_many :user_identity_google_auths, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
