# frozen_string_literal: true

class StaffIdentitySecret < IdentitiesRecord
  belongs_to :staff

  has_secure_password algorithm: :argon2
end
