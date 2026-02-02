# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_email_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_email_statuses_on_code  (code) UNIQUE
#

class StaffEmailStatus < OperatorRecord
  include CodeIdentifiable

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
  has_many :staff_emails, inverse_of: :staff_email_status, dependent: :restrict_with_error
end
