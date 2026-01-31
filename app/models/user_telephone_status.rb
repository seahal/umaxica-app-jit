# frozen_string_literal: true

class UserTelephoneStatus < PrincipalRecord
  NEYO = 0
  UNVERIFIED = 1
  VERIFIED = 2
  SUSPENDED = 3
  DELETED = 4

  has_many :user_telephones, inverse_of: :user_telephone_status, dependent: :restrict_with_error
  validates :id, uniqueness: true
  validates :id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
