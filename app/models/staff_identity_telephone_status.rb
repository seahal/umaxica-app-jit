# == Schema Information
#
# Table name: staff_identity_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class StaffIdentityTelephoneStatus < IdentitiesRecord
  include UppercaseId

  has_many :staff_identity_telephones, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
