# typed: false
# == Schema Information
#
# Table name: staff_one_time_password_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class StaffOneTimePasswordStatus < OperatorRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  DELETED = 2
  INACTIVE = 3
  NOTHING = 4
  REVOKED = 5

  has_many :staff_one_time_passwords, dependent: :restrict_with_error
end
