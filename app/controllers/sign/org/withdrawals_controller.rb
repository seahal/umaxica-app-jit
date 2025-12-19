module Sign
  module Org
    class WithdrawalsController < ApplicationController
      before_action :authenticate_staff!, only: [ :create, :update, :destroy ]

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

        Rails.event.notify("staff.deletion.request", staff_id: current_staff.id)

        begin
          Staff.transaction do
            # destroy related records that may block deletion
            StaffIdentityPasskey.where(staff_id: current_staff.id).destroy_all if defined?(StaffIdentityPasskey)
            current_staff.staff_identity_emails.destroy_all if current_staff.respond_to?(:staff_identity_emails)
            current_staff.staff_identity_telephones.destroy_all if current_staff.respond_to?(:staff_identity_telephones)
            current_staff.staff_identity_audits.destroy_all if current_staff.respond_to?(:staff_identity_audits)

            if current_staff.destroy
              reset_session
              redirect_to sign_org_root_path, notice: t("sign.org.withdrawal.destroy.deleted") and return
            else
              raise ActiveRecord::Rollback
            end
          end
        rescue ActiveRecord::InvalidForeignKey => e
          Rails.event.notify("staff.deletion.failed",
                             staff_id: current_staff.id,
                             error_message: e.message)
        end

        redirect_to sign_org_root_path, alert: t("sign.org.withdrawal.destroy.failed")
      end
    end
  end
end
