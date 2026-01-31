# frozen_string_literal: true

class UserStatus < PrincipalRecord
  NEYO = 0
  NONE = 1
  GHOST = 2
  ALIVE = 3
  ACTIVE = 4
  INACTIVE = 5
  PENDING = 6
  DELETED = 7
  WITHDRAWN = 8
  PRE_WITHDRAWAL_CONDITION = 9
  WITHDRAWAL_COMPLETED = 10
  UNVERIFIED_WITH_SIGN_UP = 11
  VERIFIED_WITH_SIGN_UP = 12
  PENDING_DELETION = 13

  has_many :users,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :user_status
  validates :id, uniqueness: true
  validates :id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
