module Sign
  module Org
    class WithdrawalsController < ApplicationController
      before_action :authenticate_staff!, only: :create

      def new
      end

      def create
        # Soft delete: set withdrawn_at to current time
        # Staff can still login for 1 month and can recover via update
        current_staff.update(withdrawn_at: Time.current)
        reset_session
        redirect_to sign_org_root_path, notice: t("sign.org.withdrawal.create.success")
      end
    end
  end
end
