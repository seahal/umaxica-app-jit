# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class StaffIdentityTelephoneStatus < OperatorRecord
  include UppercaseId

  has_many :staff_identity_telephones, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
