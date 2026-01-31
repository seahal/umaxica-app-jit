# frozen_string_literal: true

class UserOneTimePasswordStatus < PrincipalRecord
  NEYO = 0
  ACTIVE = 1
  INACTIVE = 2
  REVOKED = 3
  DELETED = 4

  has_many :user_one_time_passwords, dependent: :restrict_with_error,
                                     inverse_of: :user_one_time_password_status
  validates :id, uniqueness: true
  validates :id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
