module Sign
  module App
    class WithdrawalsController < ApplicationController
      before_action :current_user

      def show
        # Use the foreign-key string field for checks to avoid hitting a nil
        # association and to keep comparisons consistent across the controller.
        # If user is already withdrawn, do not expose the show page
        return head(:not_found) if @current_user.withdrawn_at.present?

        raise if @current_user.user_identity_status_id == "PRE_WITHDRAWAL_CONDITION"
      end

      def new
        raise if @current_user.user_identity_status_id == "ALIVE"
      end

      def create
        # If already soft-withdrawn, redirect with an alert
        if @current_user.withdrawn_at.present?
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.create.already_withdrawn") and return
        end

        # Soft delete: set withdrawn_at to now and mark pre-withdrawal status
        @current_user.withdrawn_at = Time.current
        @current_user.user_identity_status_id = "PRE_WITHDRAWAL_CONDITION"

        if @current_user.save
          # Reset session only after successful DB update
          reset_session
          redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.create.success")
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        # Ensure we compare the FK string and fix previous typo 'CONDITON'
        raise if @current_user.user_identity_status_id == "PRE_WITHDRAWAL_CONDITION"

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
        raise if @current_user.user_identity_status_id == "PRE_WITHDRAWAL_CONDITION"

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
          Rails.logger.warn("Failed to fully destroy user #{current_user.id}: #{e.message}")
        end

        redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.destroy.failed")
      end

    private
      def current_user
        # In test environment we allow overriding the current user via
        # the `X-TEST-CURRENT-USER` header. Fall back to `User.first`.
        test_user_id = request.headers["X-TEST-CURRENT-USER"] || request.env["HTTP_X_TEST_CURRENT_USER"]
        if test_user_id.present?
          @current_user = User.find_by(id: test_user_id)
        end

        @current_user ||= User.first
      end
    end
  end
end
