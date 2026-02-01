# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_telephone_statuses
# Database name: operator
#
#  id :string           not null, primary key
#

class StaffTelephoneStatus < OperatorRecord
  include CodeIdentifiable

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
  has_many :staff_telephones, inverse_of: :staff_telephone_status, dependent: :restrict_with_error
end
