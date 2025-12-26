# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_email_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class StaffIdentityEmailStatus < IdentitiesRecord
  include UppercaseId

  has_many :staff_identity_emails, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
