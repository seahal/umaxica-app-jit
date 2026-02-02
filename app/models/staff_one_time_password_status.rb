# == Schema Information
#
# Table name: staff_one_time_password_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_one_time_password_statuses_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class StaffOneTimePasswordStatus < OperatorRecord
  include CodeIdentifiable

  # Status constants
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"

  has_many :staff_one_time_passwords, dependent: :restrict_with_error
  before_validation { self.id = id&.upcase }
end
