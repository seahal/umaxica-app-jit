# frozen_string_literal: true

class UserSocialAppleStatus < PrincipalRecord
  NEYO = 0
  ACTIVE = 1
  REVOKED = 2
  DELETED = 3

  has_many :user_social_apples, inverse_of: :user_social_apple_status, dependent: :restrict_with_error
  validates :id, uniqueness: true
  validates :id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
