# frozen_string_literal: true

# == Schema Information
#
# Table name: user_email_statuses
# Database name: principal
#
#  id :string(255)      default("NEYO"), not null, primary key
#
# Indexes
#
#  index_user_identity_email_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class UserEmailStatus < PrincipalRecord
  include StringPrimaryKey

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
  has_many :user_emails, inverse_of: :user_email_status, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
