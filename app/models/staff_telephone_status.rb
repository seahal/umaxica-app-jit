# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class StaffTelephoneStatus < OperatorRecord
  include StringPrimaryKey

  has_many :staff_telephones, inverse_of: :staff_telephone_status, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
