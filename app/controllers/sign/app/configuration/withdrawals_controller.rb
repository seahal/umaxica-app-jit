# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class WithdrawalsController < ApplicationController
        before_action :authenticate_user!

        def create
          # Update user status and schedule purge
          current_user.transaction do
            current_user.status_id = "PENDING_DELETION"
            current_user.scheduled_purge_at = 30.days.from_now
            current_user.save!(validate: false) # validate: false if status invalid

            # Revoke all tokens
            current_user.user_tokens.where(revoked_at: nil).find_each(&:revoke!)
          end

          # Clear current session (log out)
          log_out
          redirect_to sign_app_root_path, notice: t("sign.app.configuration.withdrawal.create.success")
        end
      end
    end
  end
end
