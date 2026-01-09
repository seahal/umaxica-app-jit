# frozen_string_literal: true

# == Schema Information
#
# Table name: user_email_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class UserEmailStatus < PrincipalRecord
  include StringPrimaryKey

  has_many :user_emails, inverse_of: :user_email_status, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
