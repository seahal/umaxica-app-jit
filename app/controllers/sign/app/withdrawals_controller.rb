module Sign
  module App
    class WithdrawalsController < ApplicationController
      before_action :authenticate_user!, only: :create

      # note: you would surprise to think that new is not good for this method,
      #       but you should think that create delete flag to this
      def new
      end

      def create
        # Soft delete: set withdrawn_at to current time
        # User can still login for 1 month and can recover via update
        current_user.update(withdrawn_at: Time.current)
        reset_session
        redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.create.success")
      end
    end
  end
end
