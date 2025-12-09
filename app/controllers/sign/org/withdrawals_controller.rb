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
        if current_staff.withdrawn?
          redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.create.already_withdrawn")
          return
        end

        # Soft delete: set withdrawn_at to current time
        if current_staff.update(withdrawn_at: Time.current)
          reset_session
          redirect_to sign_org_root_path, notice: t("sign.org.withdrawal.create.success")
        else
          redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.create.failed")
        end
      end

      def update
        # Recovery: clear withdrawn_at if within the model-configured recovery window
        if current_staff.can_recover?
          if current_staff.update(withdrawn_at: nil)
            redirect_to sign_org_root_path, notice: t("sign.org.withdrawal.update.recovered")
          else
            redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.update.failed")
          end
        else
          redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.update.cannot_recover")
        end
      end

      def destroy
        # Only allow permanent removal if staff was previously withdrawn
        unless current_staff.withdrawn?
          redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.destroy.not_withdrawn") and return
        end

        Rails.logger.info("Permanent staff deletion requested: #{current_staff.id}")

        Staff.transaction do
          if current_staff.destroy
            reset_session
            redirect_to sign_org_root_path, notice: t("sign.org.withdrawal.destroy.deleted") and return
          else
            raise ActiveRecord::Rollback
          end
        end

        redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.destroy.failed")
      end
    end
  end
end
