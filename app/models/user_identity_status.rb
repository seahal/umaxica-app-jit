class UserIdentityStatus < IdentitiesRecord
  include UppercaseId

  has_many :users, dependent: :restrict_with_error

  # Status constants
  NONE = "NONE"
  ALIVE = "ALIVE"
  PRE_WITHDRAWAL_CONDITION = "PRE_WITHDRAWAL_CONDITION"
  WITHDRAWAL_COMPLETED = "WITHDRAWAL_COMPLETED"
end
