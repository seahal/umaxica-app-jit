# frozen_string_literal: true

class StaffToken < TokensRecord
  MAX_SESSIONS_PER_STAFF = 2

  belongs_to :staff
  belongs_to :staff_token_status

  validate :enforce_concurrent_session_limit, on: :create

  private

  def enforce_concurrent_session_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_SESSIONS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum concurrent sessions per staff (#{MAX_SESSIONS_PER_STAFF})")
  end
end
