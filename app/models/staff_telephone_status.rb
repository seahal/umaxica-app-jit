# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class StaffTelephoneStatus < OperatorRecord
  include UppercaseId

  has_many :staff_telephones, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
