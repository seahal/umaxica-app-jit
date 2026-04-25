# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_email_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#
class UserEmailStatus < PrincipalRecord
  UNVERIFIED = 1
  VERIFIED = 2
  SUSPENDED = 3
  DELETED = 4
  NOTHING = 5
  UNVERIFIED_WITH_SIGN_UP = 6
  VERIFIED_WITH_SIGN_UP = 7
  OAUTH_LINKED = 8

  has_many :user_emails, inverse_of: :user_email_status, dependent: :restrict_with_error
end
