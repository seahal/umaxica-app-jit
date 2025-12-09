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
        if current_user.withdrawn_at.present?
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.create.already_withdrawn")
          return
        end

        # Soft delete: set withdrawn_at to current time
        # User can still login for 1 month and can recover via update
        current_user.update(withdrawn_at: Time.current)
        reset_session
        redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.create.success")
      end

      def update
        # Recovery: clear withdrawn_at if within 1 month
        if current_user.withdrawn_at.present? && current_user.withdrawn_at > 1.month.ago
          current_user.update(withdrawn_at: nil)
          redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.update.recovered")
        else
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.update.cannot_recover")
        end
      end

      def destroy
        # Only allow permanent removal if account was previously withdrawn
        if current_user.withdrawn_at.present?
          current_user.destroy
          reset_session
          redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.destroy.deleted")
        else
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.destroy.not_withdrawn")
        end
      end
    end
  end
end
