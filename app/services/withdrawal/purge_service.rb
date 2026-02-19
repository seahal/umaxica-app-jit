# frozen_string_literal: true

module Withdrawal
  class PurgeService
    def initialize(user)
      @user = user
    end

    # Permanently purges PII and revokes credentials for a withdrawn user.
    #
    # Execution order:
    #   1. Revoke all tokens (token DB, separate connection)
    #   2. Destroy PII associations (principal DB, within a transaction)
    #   3. Mark the user record as purged
    #   4. Emit audit event
    #
    # Note: Steps 1 and 2-3 run on different database connections and are NOT
    # guaranteed to be atomic across databases. If token revocation succeeds but
    # PII destruction fails, tokens will be revoked but user data will remain.
    # Retry logic or a background job should be used to handle partial failures.
    def call
      revoke_tokens!
      PrincipalRecord.transaction do
        destroy_pii!
        mark_purged!
      end
      Rails.event.notify("user.purged", user_id: @user.id)
    rescue StandardError => e
      Rails.logger.error("[Withdrawal::PurgeService] Failed to purge user #{@user.id}: #{e.message}")
      Rails.error.report(e, context: { user_id: @user.id })
      raise
    end

    private

    def revoke_tokens!
      TokenRecord.connected_to(role: :writing) do
        UserToken
          .where(user_id: @user.id, revoked_at: nil)
          # rubocop:disable Rails/SkipsModelValidations
          .update_all(revoked_at: Time.current, updated_at: Time.current)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    def destroy_pii!
      @user.user_emails.destroy_all
      @user.user_telephones.destroy_all
      @user.user_secrets.destroy_all
      @user.user_passkeys.destroy_all
      @user.user_one_time_passwords.destroy_all
      @user.user_social_apple&.destroy
      @user.user_social_google&.destroy
    end

    def mark_purged!
      @user.update!(
        purged_at: Time.current,
        status_id: UserStatus::WITHDRAWN,
      )
    end
  end
end
