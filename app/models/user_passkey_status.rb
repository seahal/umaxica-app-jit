# frozen_string_literal: true

class UserPasskeyStatus < PrincipalRecord
  NEYO = 0
  ACTIVE = 1
  DISABLED = 2
  DELETED = 3

  has_many :user_passkeys, dependent: :restrict_with_error

  validates :id, uniqueness: true
  validates :id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
