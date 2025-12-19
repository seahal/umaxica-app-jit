module Sign
  module App
    class WithdrawalsController < ApplicationController
      before_action :authenticate_user!

      def new
        # NOTE: change this status check according to your business logic
        raise InvalidUserStatusError.new(invalid_status: "new is not implemented") unless current_user.user_identity_status_id == "NONE"
      end

      def create
        # NOTE: change this status check according to your business logic
        raise InvalidUserStatusError.new(invalid_status: "new is not implemented") unless current_user.user_identity_status_id == "NONE"

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
        begin
          User.transaction do
            current_user.destroy!
            reset_session
            redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.destroy.success")
          end
        rescue StandardError => e
          Rails.event.notify("user.deletion.failed", error_message: e.message)
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.destroy.failed")
        end
      end
    end
  end
end
