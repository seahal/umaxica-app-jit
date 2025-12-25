# == Schema Information
#
# Table name: user_identity_secret_statuses
#
#  id :string(255)      not null, primary key
#

class UserIdentitySecretStatus < IdentitiesRecord
  include UppercaseId

  has_many :user_identity_secrets, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  EXPIRED = "EXPIRED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
