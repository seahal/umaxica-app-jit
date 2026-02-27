# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_telephone_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#
class UserTelephoneStatus < PrincipalRecord
  UNVERIFIED = 1
  VERIFIED = 2
  SUSPENDED = 3
  DELETED = 4
  NOTHING = 5
  UNVERIFIED_WITH_SIGN_UP = 6
  VERIFIED_WITH_SIGN_UP = 7

  has_many :user_telephones, inverse_of: :user_telephone_status, dependent: :restrict_with_error
end
