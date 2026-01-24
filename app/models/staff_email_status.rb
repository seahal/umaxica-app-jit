# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_email_statuses
# Database name: operator
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#
# Indexes
#
#  index_staff_identity_email_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class StaffEmailStatus < OperatorRecord
  include StringPrimaryKey

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
  has_many :staff_emails, inverse_of: :staff_email_status, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
