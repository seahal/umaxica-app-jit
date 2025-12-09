module Sign
  module Org
    class WithdrawalsController < ApplicationController
      before_action :authenticate_staff!, only: [ :show, :create, :update, :destroy ]

      def show
        # Show withdrawal status for the current staff
        @withdrawn_at = current_staff.withdrawn_at
      end
      def new
      end


      def create
        # Check if staff is already withdrawn
        if current_staff.withdrawn_at.present?
          redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.create.already_withdrawn")
          return
        end

        # Soft delete: set withdrawn_at to current time
        # Staff can still login for 1 month and can recover via update
        current_staff.update(withdrawn_at: Time.current)
        reset_session
        redirect_to sign_org_root_path, notice: t("sign.org.withdrawal.create.success")
      end

      def update
        # Recovery: clear withdrawn_at if within 1 month
        if current_staff.withdrawn_at.present? && current_staff.withdrawn_at > 1.month.ago
          current_staff.update(withdrawn_at: nil)
          redirect_to sign_org_root_path, notice: t("sign.org.withdrawal.update.recovered")
        else
          redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.update.cannot_recover")
        end
      end

      def destroy
        # Only allow permanent removal if staff was previously withdrawn
        if current_staff.withdrawn_at.present?
          current_staff.destroy
          reset_session
          redirect_to sign_org_root_path, notice: t("sign.org.withdrawal.destroy.deleted")
        else
          redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.destroy.not_withdrawn")
        end
      end
    end
  end
end
