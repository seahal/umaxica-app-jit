# frozen_string_literal: true

class UserIdentityOneTimePasswordStatus < IdentitiesRecord
  has_many :user_identity_one_time_passwords, dependent: :restrict_with_error, inverse_of: :user_identity_one_time_password_status

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true

  # Status constants
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
