# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_email_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class StaffEmailStatus < OperatorRecord
  include StringPrimaryKey

  validates :id, uniqueness: { case_sensitive: false }

  has_many :staff_emails, inverse_of: :staff_email_status, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
