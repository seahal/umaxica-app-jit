# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_passkey_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#

class StaffPasskeyStatus < OperatorRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  REVOKED = 2

  has_many :staff_passkeys, dependent: :restrict_with_error
end
