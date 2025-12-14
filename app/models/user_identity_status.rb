class UserIdentityStatus < IdentitiesRecord
  has_many :users, dependent: :restrict_with_error

  before_validation { self.id = id&.upcase }
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[A-Z0-9_]+\z/ }

  # Status constants
  NONE = "NONE"
  ALIVE = "ALIVE"
  PRE_WITHDRAWAL_CONDITION = "PRE_WITHDRAWAL_CONDITION"
  WITHDRAWAL_COMPLETED = "WITHDRAWAL_COMPLETED"
end
