# frozen_string_literal: true

module Sign
  module App
    module In
      class MfasController < ApplicationController
        before_action :reject_logged_in_session
        before_action :ensure_pending_mfa!

        def show
          @mfa_user = pending_mfa_user
          @can_use_totp = @mfa_user&.totp_enabled?
          @can_use_passkey = @mfa_user&.user_passkeys&.exists?(user_passkey_status_id: UserPasskeyStatus::ACTIVE)
        end

        private

        def ensure_pending_mfa!
          if !pending_mfa_valid? || pending_mfa_user.nil?
            clear_pending_mfa!
            redirect_to new_sign_app_in_path, status: :see_other
          end
        end
      end
    end
  end
end
