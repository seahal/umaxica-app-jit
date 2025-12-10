module Sign
  module App
    class WithdrawalsController < ApplicationController
      before_action :authenticate_user!
      before_action :check_withdrawal_state, only: %i[show update destroy]

      def show
        # Use the foreign-key string field for checks to avoid hitting a nil
        # association and to keep comparisons consistent across the controller.
        # If user is already withdrawn, do not expose the show page
        head(:not_found) if current_user.withdrawn_at.present?
      end

      def new
        # Ensure user is in ALIVE state before showing withdrawal form
        unless current_user.user_identity_status_id == UserIdentityStatus::ALIVE
          raise Sign::InvalidWithdrawalStateError.new(current_user.user_identity_status_id)
        end
      end

      def create
        # If already soft-withdrawn, redirect with an alert
        if current_user.withdrawn_at.present?
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.create.already_withdrawn") and return
        end

        # Soft delete: set withdrawn_at to now and mark pre-withdrawal status
        current_user.withdrawn_at = Time.current
        current_user.user_identity_status_id = UserIdentityStatus::PRE_WITHDRAWAL_CONDITION

        if current_user.save
          # Reset session only after successful DB update
          reset_session
          redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.create.success")
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        # Recovery: clear withdrawn_at if within the model-configured recovery window
        if current_user.can_recover?
          if current_user.update(withdrawn_at: nil)
            redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.update.recovered")
          else
            redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.update.failed")
          end
        else
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.update.cannot_recover")
        end
      end

      def destroy
        # Log intent and perform destroy inside a transaction. Prefer background job
        # for heavy deletions; here we attempt synchronous destroy with graceful handling.

        # Remove associated records that enforce FK constraints first.
        begin
          User.transaction do
            # destroy related records that may block deletion
            UserIdentityPasskey.where(user_id: current_user.id).destroy_all
            current_user.user_identity_emails.destroy_all if current_user.respond_to?(:user_identity_emails)
            current_user.user_identity_telephones.destroy_all if current_user.respond_to?(:user_identity_telephones)
            current_user.user_time_based_one_time_password.destroy_all if current_user.respond_to?(:user_time_based_one_time_password)
            current_user.user_webauthn_credentials.destroy_all if current_user.respond_to?(:user_webauthn_credentials)
            current_user.user_identity_audits.destroy_all if current_user.respond_to?(:user_identity_audits)
            current_user.user_tokens.destroy_all if current_user.respond_to?(:user_tokens)

            if current_user.destroy
              reset_session
              redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.destroy.deleted") and return
            else
              raise ActiveRecord::Rollback
            end
          end
        rescue ActiveRecord::InvalidForeignKey => e
          Rails.logger.error("Failed to fully destroy user #{current_user.id}: #{e.message}")
          raise Sign::WithdrawalDeletionError.new
        end

        redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.destroy.failed")
      end

    private

      def set_current_user
        @current_user = current_user
      end

      def check_withdrawal_state
        # Ensure user is authenticated and in PRE_WITHDRAWAL_CONDITION state for these actions
        unless current_user.user_identity_status_id == UserIdentityStatus::PRE_WITHDRAWAL_CONDITION
          raise Sign::InvalidWithdrawalStateError.new(current_user.user_identity_status_id)
        end
      end
    end
  end
end
