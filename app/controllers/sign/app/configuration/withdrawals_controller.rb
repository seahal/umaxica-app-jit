# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class WithdrawalsController < ApplicationController
        before_action :authenticate_user!

        def show
        end

        def new
          # NOTE: change this status check according to your business logic
          unless current_user.status_id == "NEYO"
            raise InvalidUserStatusError.new(invalid_status: "new is not implemented")
          end
        end

        def edit
        end

        def create
          # NOTE: change this status check according to your business logic
          unless current_user.status_id == "NEYO"
            raise InvalidUserStatusError.new(invalid_status: "new is not implemented")
          end

          # Soft delete: set withdrawn_at to now and mark pre-withdrawal status
          current_user.withdrawn_at = Time.current
          current_user.status_id = UserStatus::PRE_WITHDRAWAL_CONDITION

          if current_user.save
            process_withdrawal_success
          else
            process_withdrawal_failure
          end
        end

        def update
          # Recovery: clear withdrawn_at if within the model-configured recovery window
          if current_user.can_recover?
            attempt_recovery
          else
            reject_recovery
          end
        end

        private

        def process_withdrawal_success
          User.transaction do
            Rails.event.notify(
              "user.withdrawal.initiated",
              user_id: current_user.id,
              withdrawn_at: current_user.withdrawn_at,
              status: UserStatus::PRE_WITHDRAWAL_CONDITION,
              ip_address: request.remote_ip,
            )
            # Log out and clear session data
            log_out
            redirect_to sign_app_root_path, notice: t("sign.app.configuration.withdrawal.create.success")
          end
        end

        def process_withdrawal_failure
          Rails.event.notify(
            "user.withdrawal.initiation_failed",
            user_id: current_user.id,
            errors: current_user.errors.full_messages,
            ip_address: request.remote_ip,
          )
          render :new, status: :unprocessable_content
        end

        def attempt_recovery
          if current_user.update(withdrawn_at: nil)
            Rails.event.notify(
              "user.withdrawal.recovered",
              user_id: current_user.id,
              ip_address: request.remote_ip,
            )
            redirect_to sign_app_root_path, notice: t("sign.app.configuration.withdrawal.update.recovered")
          else
            process_recovery_failure
          end
        end

        def process_recovery_failure
          Rails.event.notify(
            "user.withdrawal.recovery_failed",
            user_id: current_user.id,
            errors: current_user.errors.full_messages,
            ip_address: request.remote_ip,
          )
          redirect_to sign_app_root_path, alert: t("sign.app.configuration.withdrawal.update.failed")
        end

        def reject_recovery
          Rails.event.notify(
            "user.withdrawal.recovery_rejected",
            user_id: current_user.id,
            reason: "recovery_window_expired",
            ip_address: request.remote_ip,
          )
          redirect_to sign_app_root_path, alert: t("sign.app.configuration.withdrawal.update.cannot_recover")
        end

        def destroy
          # Log intent and perform destroy inside a transaction. Prefer background job
          # for heavy deletions; here we attempt synchronous destroy with graceful handling.
          user_id = current_user.id
          begin
            process_deletion(user_id)
          rescue StandardError => e
            handle_deletion_failure(user_id, e)
          end
        end

        def process_deletion(user_id)
          User.transaction do
            current_user.destroy!
            Rails.event.notify(
              "user.deletion.completed",
              user_id: user_id,
              ip_address: request.remote_ip,
            )
            log_out
            redirect_to sign_app_root_path, notice: t("sign.app.configuration.withdrawal.destroy.success")
          end
        end

        def handle_deletion_failure(user_id, error)
          Rails.event.notify(
            "user.deletion.failed",
            user_id: user_id,
            error_class: error.class.name,
            error_message: error.message,
            ip_address: request.remote_ip,
          )
          redirect_to sign_app_root_path, alert: t("sign.app.configuration.withdrawal.destroy.failed")
        end
      end
    end
  end
end
