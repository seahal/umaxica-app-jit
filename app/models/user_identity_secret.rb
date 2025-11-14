# frozen_string_literal: true

class UserIdentitySecret < IdentitiesRecord
  belongs_to :user

  has_secure_password algorithm: :argon2
end
