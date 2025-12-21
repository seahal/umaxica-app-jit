# frozen_string_literal: true

class StaffToken < TokensRecord
  MAX_SESSIONS_PER_STAFF = 2

  belongs_to :staff
  belongs_to :staff_token_status

  validate :enforce_concurrent_session_limit, on: :create

  private

    # This is a model-level validation to provide a friendly error message to the user.
    # The primary enforcement of the session limit is done by a database trigger,
    # which is more reliable and avoids race conditions.
    def enforce_concurrent_session_limit
      return unless staff_id

      count = self.class.where(staff_id: staff_id).count
      return if count < MAX_SESSIONS_PER_STAFF

      errors.add(:base, :too_many, message: "exceeds maximum concurrent sessions per staff (#{MAX_SESSIONS_PER_STAFF})")
    end
end
