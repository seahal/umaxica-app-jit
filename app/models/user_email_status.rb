# frozen_string_literal: true

# == Schema Information
#
# Table name: user_email_statuses
# Database name: principal
#
#  id :integer          not null, primary key
#
class UserEmailStatus < PrincipalRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
  has_many :user_emails, inverse_of: :user_email_status, dependent: :restrict_with_error
end
