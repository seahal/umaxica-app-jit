# frozen_string_literal: true

# == Schema Information
#
# Table name: user_statuses
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_statuses_on_code  (code) UNIQUE
#
class UserStatus < PrincipalRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  NONE = "NONE"
  GHOST = "GHOST"
  ALIVE = "ALIVE"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  PENDING = "PENDING"
  DELETED = "DELETED"
  WITHDRAWN = "WITHDRAWN"
  PRE_WITHDRAWAL_CONDITION = "PRE_WITHDRAWAL_CONDITION"
  WITHDRAWAL_COMPLETED = "WITHDRAWAL_COMPLETED"
  UNVERIFIED_WITH_SIGN_UP = "UNVERIFIED_WITH_SIGN_UP"
  VERIFIED_WITH_SIGN_UP = "VERIFIED_WITH_SIGN_UP"
  PENDING_DELETION = "PENDING_DELETION"
  has_many :users,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :user_status
end
