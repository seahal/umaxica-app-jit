module Sign
  module Org
    class WithdrawalsController < ApplicationController
      before_action :authenticate_staff!, only: :create

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
    end
  end
end
