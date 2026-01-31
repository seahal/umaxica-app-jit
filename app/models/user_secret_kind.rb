# frozen_string_literal: true

class UserSecretKind < PrincipalRecord
  LOGIN = 1
  TOTP = 2
  RECOVERY = 3
  API = 4

  ALL = [LOGIN, TOTP, RECOVERY, API].freeze

  has_many :user_secrets, inverse_of: :user_secret_kind, dependent: :restrict_with_exception

  validates :id, uniqueness: true
  validates :id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
