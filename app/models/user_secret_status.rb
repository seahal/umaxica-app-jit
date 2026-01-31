# frozen_string_literal: true

class UserSecretStatus < PrincipalRecord
  NEYO = 0
  ACTIVE = 1
  USED = 2
  EXPIRED = 3
  REVOKED = 4
  DELETED = 5

  has_many :user_secrets, inverse_of: :user_secret_status, dependent: :restrict_with_error
  validates :id, uniqueness: true
  validates :id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
