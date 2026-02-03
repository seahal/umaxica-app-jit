# frozen_string_literal: true

# == Schema Information
#
# Table name: user_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#
class UserStatus < PrincipalRecord
  ACTIVE = 1
  INACTIVE = 2
  PENDING = 3
  DELETED = 4
  WITHDRAWN = 5
  PENDING_DELETION = 6
  PRE_WITHDRAWAL_CONDITION = 7
  WITHDRAWAL_COMPLETED = 8
  UNVERIFIED_WITH_SIGN_UP = 9
  VERIFIED_WITH_SIGN_UP = 10
  NEYO = 11
  GHOST = 12
  NONE = 13

  has_many :users,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :user_status
end
