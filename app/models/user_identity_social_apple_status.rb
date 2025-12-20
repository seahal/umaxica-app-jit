# frozen_string_literal: true

class UserIdentitySocialAppleStatus < IdentitiesRecord
  include UppercaseId

  has_many :user_identity_social_apples, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
