class StaffIdentitySecret < IdentitiesRecord
  MAX_SECRETS_PER_STAFF = 10

  belongs_to :staff
  belongs_to :staff_identity_secret_status, optional: true

  has_secure_password algorithm: :argon2

  validates :name, presence: true
  validate :enforce_staff_secret_limit, on: :create

  private

    def enforce_staff_secret_limit
      return unless staff_id

      count = self.class.where(staff_id: staff_id).count
      return if count < MAX_SECRETS_PER_STAFF

      errors.add(:base, :too_many, message: "exceeds maximum secrets per staff (#{MAX_SECRETS_PER_STAFF})")
    end
end
