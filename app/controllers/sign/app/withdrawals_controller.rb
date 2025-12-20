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
          Rails.event.notify("user.withdrawal.initiated",
                             user_id: current_user.id,
                             withdrawn_at: current_user.withdrawn_at,
                             status: UserIdentityStatus::PRE_WITHDRAWAL_CONDITION,
                             ip_address: request.remote_ip
          )
          # Reset session only after successful DB update
          reset_session
          redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.create.success")
        else
          Rails.event.notify("user.withdrawal.initiation_failed",
                             user_id: current_user.id,
                             errors: current_user.errors.full_messages,
                             ip_address: request.remote_ip
          )
          render :new, status: :unprocessable_content
        end
      end

      def update
        # Recovery: clear withdrawn_at if within the model-configured recovery window
        if current_user.can_recover?
          if current_user.update(withdrawn_at: nil)
            Rails.event.notify("user.withdrawal.recovered",
                               user_id: current_user.id,
                               ip_address: request.remote_ip
            )
            redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.update.recovered")
          else
            Rails.event.notify("user.withdrawal.recovery_failed",
                               user_id: current_user.id,
                               errors: current_user.errors.full_messages,
                               ip_address: request.remote_ip
            )
            redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.update.failed")
          end
        else
          Rails.event.notify("user.withdrawal.recovery_rejected",
                             user_id: current_user.id,
                             reason: "recovery_window_expired",
                             ip_address: request.remote_ip
          )
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.update.cannot_recover")
        end
      end

      def destroy
        # Log intent and perform destroy inside a transaction. Prefer background job
        # for heavy deletions; here we attempt synchronous destroy with graceful handling.
        user_id = current_user.id
        begin
          User.transaction do
            current_user.destroy!
            Rails.event.notify("user.deletion.completed",
                               user_id: user_id,
                               ip_address: request.remote_ip
            )
            reset_session
            redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.destroy.success")
          end
        rescue StandardError => e
          Rails.event.notify("user.deletion.failed",
                             user_id: user_id,
                             error_class: e.class.name,
                             error_message: e.message,
                             ip_address: request.remote_ip
          )
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.destroy.failed")
        end
      end
    end
  end
end
