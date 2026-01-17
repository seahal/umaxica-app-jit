# frozen_string_literal: true

# Rotates refresh tokens using the public_id/verifier format.
# Keeps verification centralized and raises a dedicated error on failure.
#
# Atomicity:
# - Uses transaction + row lock (SELECT ... FOR UPDATE) for serialization
# - Prevents concurrent refresh attempts and replay attacks
# - LockWaitTimeout / Deadlocked treated as InvalidRefreshToken (401)
module Sign
  class RefreshTokenService
    # Lock wait timeout exceptions vary by database adapter
    LOCK_EXCEPTIONS = [
      ActiveRecord::LockWaitTimeout,
      ActiveRecord::Deadlocked,
    ].freeze

    def self.call(refresh_token:)
      new(refresh_token).call
    end

    def initialize(refresh_token)
      @refresh_token = refresh_token
    end

    def call
      public_id, verifier = parse_refresh_token!

      TokenRecord.connected_to(role: :writing) do
        TokenRecord.transaction do
          token = find_and_lock_token(public_id)
          raise InvalidRefreshToken, "token_not_found" unless token
          raise InvalidRefreshToken, "inactive_token" unless token.active?
          raise InvalidRefreshToken, "invalid_verifier" unless token.authenticate_refresh_token(verifier)

          # Rotate and return new refresh token
          new_refresh_token = token.rotate_refresh_token!
          { token: token, refresh_token: new_refresh_token }
        end
      end
    rescue *LOCK_EXCEPTIONS => e
      # Treat lock contention as invalid token (prevents timing attacks)
      Rails.event.notify(
        "authentication.refresh.lock_contention",
        error_class: e.class.name,
        public_id: public_id,
      )
      raise InvalidRefreshToken, "concurrent_refresh_detected"
    end

    private

    def parse_refresh_token!
      parsed = UserToken.parse_refresh_token(@refresh_token)
      raise InvalidRefreshToken, "invalid_format" unless parsed

      parsed
    end

    def find_and_lock_token(public_id)
      # Try UserToken first, then StaffToken
      # Use lock (FOR UPDATE) to prevent concurrent modifications
      UserToken.lock.find_by(public_id: public_id, rotated_at: nil) ||
        StaffToken.lock.find_by(public_id: public_id, rotated_at: nil)
    end
  end
end
