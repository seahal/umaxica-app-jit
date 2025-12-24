# == Schema Information
#
# Table name: staff_identity_secret_statuses
#
#  id :string(255)      not null, primary key
#

class StaffIdentitySecretStatus < IdentitiesRecord
  include UppercaseId

  has_many :staff_identity_secrets, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
