# frozen_string_literal: true

# == Schema Information
#
# Table name: user_statuses
# Database name: principal
#
#  id :string(255)      default("NEYO"), not null, primary key
#
# Indexes
#
#  index_user_identity_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class UserStatus < PrincipalRecord
  include StringPrimaryKey

  # Status constants
  NONE = "NONE"
  GHOST = "GHOST"
  ALIVE = "ALIVE"
  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  PENDING = "PENDING"
  DELETED = "DELETED"
  WITHDRAWN = "WITHDRAWN"
  PRE_WITHDRAWAL_CONDITION = "PRE_WITHDRAWAL_CONDITION"
  WITHDRAWAL_COMPLETED = "WITHDRAWAL_COMPLETED"
  UNVERIFIED_WITH_SIGN_UP = "UNVERIFIED_WITH_SIGN_UP"
  VERIFIED_WITH_SIGN_UP = "VERIFIED_WITH_SIGN_UP"
  has_many :users,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :user_status
  validates :id, uniqueness: { case_sensitive: false }
end
