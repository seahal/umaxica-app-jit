# frozen_string_literal: true

class UserIdentityAppleAuthStatus < IdentitiesRecord
  include UppercaseIdValidation

  has_many :user_identity_apple_auths, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
