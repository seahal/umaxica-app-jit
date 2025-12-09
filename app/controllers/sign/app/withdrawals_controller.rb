module Sign
  module App
    class WithdrawalsController < ApplicationController
      before_action :authenticate_user!, only: [ :show, :create, :update, :destroy ]

      def show
        # Show withdrawal status page for the current user
        @withdrawn_at = current_user.withdrawn_at
      end
      # note: you would surprise to think that new is not good for this method,
      #       but you should think that create delete flag to this
      def new
      end


      def create
        # Check if user is already withdrawn
        if current_user.withdrawn?
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.create.already_withdrawn")
          return
        end

        # Soft delete: set withdrawn_at to current time
        if current_user.update(withdrawn_at: Time.current)
          # Reset session only after successful DB update
          reset_session
          redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.create.success")
        else
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.create.failed")
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
        # Only allow permanent removal if account was previously withdrawn
        unless current_user.withdrawn?
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.destroy.not_withdrawn") and return
        end

        # Log intent and perform destroy inside a transaction. Prefer background job
        # for heavy deletions; here we attempt synchronous destroy with graceful handling.
        Rails.logger.info("Permanent user deletion requested: #{current_user.id}")

        User.transaction do
          if current_user.destroy
            reset_session
            redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.destroy.deleted") and return
          else
            raise ActiveRecord::Rollback
          end
        end

        redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.destroy.failed")
      end
    end
  end
end
