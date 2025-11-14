# frozen_string_literal: true

class StaffIdentitySecret < IdentitiesRecord
  MAX_SECRETS_PER_STAFF = 10

  belongs_to :staff

  has_secure_password algorithm: :argon2

  validate :enforce_staff_secret_limit, on: :create

  private

  def enforce_staff_secret_limit
    return unless staff_id

    count = StaffIdentitySecret.where(staff_id: staff_id).count
    return if count < MAX_SECRETS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum secrets per staff (#{MAX_SECRETS_PER_STAFF})")
  end
end
