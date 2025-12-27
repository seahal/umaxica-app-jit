# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_email_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class UserIdentityEmailStatus < IdentitiesRecord
  include UppercaseId

  has_many :user_identity_emails, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
