# frozen_string_literal: true

# == Schema Information
#
# Table name: user_email_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class UserEmailStatus < PrincipalRecord
  include UppercaseId

  has_many :user_emails, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
