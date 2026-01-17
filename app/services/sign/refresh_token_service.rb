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

      result = nil
      reused_token = nil
      execution_proc =
        -> {
          TokenRecord.transaction do
            token = find_and_lock_token(public_id)
            raise InvalidRefreshToken, "token_not_found" unless token
            raise InvalidRefreshToken, "inactive_token" unless token.active?

            if token.refresh_token_digest_matches?(verifier)
              # Rotate and return new refresh token
              new_refresh_token = token.rotate_refresh_token!
              result = { token: token, refresh_token: new_refresh_token }
            else
              reused_token = token
              raise ActiveRecord::Rollback
            end
          end
        }

      if Rails.env.test?
        execution_proc.call
      else
        TokenRecord.connected_to(role: :writing, &execution_proc)
      end

      return result if result

      if reused_token
        handle_refresh_token_reuse(reused_token)
        raise InvalidRefreshToken, "refresh_token_reuse_detected"
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

    # When reuse is observed (a valid token that no longer matches the
    # stored digest), we treat the event as a compromise and revoke all
    # tokens belonging to the same actor (user or staff). This is logged
    # without the raw refresh verifier to avoid exposing secrets.
    def handle_refresh_token_reuse(token)
      actor_scope = actor_tokens_scope(token)
      now = Time.current
      actor_scope.find_each do |actor|
        actor.update!(revoked_at: now, compromised_at: now)
      end

      Rails.event.notify(
        "authentication.refresh.reuse_detected",
        token_id: token.public_id,
        refresh_token_family_id: token.refresh_token_family_id,
        actor_type: actor_type_label(token),
        actor_id: actor_identifier(token),
      )
    end

    def actor_tokens_scope(token)
      column = actor_identifier_column(token)
      return token.class.where(id: token.id) unless column

      token.class.where(column => token.public_send(column))
    end

    def actor_identifier_column(token)
      return :user_id if token.respond_to?(:user_id) && token.user_id.present?
      return :staff_id if token.respond_to?(:staff_id) && token.staff_id.present?

      nil
    end

    def actor_identifier(token)
      column = actor_identifier_column(token)
      column ? token.public_send(column) : nil
    end

    def actor_type_label(token)
      actor_identifier_column(token)&.to_s&.delete_suffix("_id")
    end
  end
end
