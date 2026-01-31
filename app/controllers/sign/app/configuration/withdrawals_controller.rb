# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class WithdrawalsController < ApplicationController
        include ::Auth::StepUp

        before_action :authenticate_user!
        before_action -> { require_step_up!(scope: "withdrawal") }

        def show
        end

        def new
          # NOTE: change this status check according to your business logic
          unless current_user.status_id == UserStatus::NEYO
            raise InvalidUserStatusError.new(invalid_status: "new is not implemented")
          end
        end

        def edit
        end

        def create
          # NOTE: change this status check according to your business logic
          unless current_user.status_id == UserStatus::NEYO
            raise InvalidUserStatusError.new(invalid_status: "new is not implemented")
          end

          # Soft delete: set withdrawn_at to now and mark pre-withdrawal status
          begin
            User.transaction do
              current_user.withdrawn_at = Time.current
              current_user.status_id = UserStatus::PRE_WITHDRAWAL_CONDITION
              current_user.save!

              Rails.event.notify(
                "user.withdrawal.initiated",
                user_id: current_user.id,
                withdrawn_at: current_user.withdrawn_at,
                status: UserStatus::PRE_WITHDRAWAL_CONDITION,
                ip_address: request.remote_ip,
              )

              # Log out and clear session data
              log_out
            end
            redirect_to sign_app_root_path, notice: t("sign.app.configuration.withdrawal.create.success")
          rescue ActiveRecord::RecordInvalid
            Rails.event.notify(
              "user.withdrawal.initiation_failed",
              user_id: current_user.id,
              errors: current_user.errors.full_messages,
              ip_address: request.remote_ip,
            )
            render :new, status: :unprocessable_content
          end
        end

        def update
          # Recovery: clear withdrawn_at if within the model-configured recovery window
          if current_user.can_recover?
            User.transaction do
              current_user.update!(withdrawn_at: nil)
              Rails.event.notify(
                "user.withdrawal.recovered",
                user_id: current_user.id,
                ip_address: request.remote_ip,
              )
            end
            redirect_to sign_app_root_path, notice: t("sign.app.configuration.withdrawal.update.recovered")
          else
            reject_recovery
          end
        rescue ActiveRecord::RecordInvalid
          Rails.event.notify(
            "user.withdrawal.recovery_failed",
            user_id: current_user.id,
            errors: current_user.errors.full_messages,
            ip_address: request.remote_ip,
          )
          redirect_to sign_app_root_path, alert: t("sign.app.configuration.withdrawal.update.failed")
        end

        def destroy
          # BLOCKED: Step2 (permanent deletion) is not available in this implementation.
          # Only Step1 (logical withdrawal via PRE_WITHDRAWAL_CONDITION) is supported.
          # Permanent deletion will be implemented separately as a future feature.
          Rails.event.notify(
            "user.deletion.blocked",
            user_id: current_user.id,
            ip_address: request.remote_ip,
            reason: "step2_not_implemented",
          )

          if request.format.json?
            render json: { error: "PERMANENT_DELETION_NOT_AVAILABLE" }, status: :forbidden
          else
            redirect_to edit_sign_app_configuration_withdrawal_path,
                        alert: t("sign.app.configuration.withdrawal.destroy.permanent_unavailable")
          end
        end

        private

        def reject_recovery
          Rails.event.notify(
            "user.withdrawal.recovery_rejected",
            user_id: current_user.id,
            withdrawn_at: current_user.withdrawn_at,
            ip_address: request.remote_ip,
          )
          redirect_to sign_app_root_path, alert: t("sign.app.configuration.withdrawal.update.cannot_recover")
        end
      end
    end
  end
end
