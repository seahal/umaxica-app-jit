module Sign
  module App
    class WithdrawalsController < ApplicationController
      # note: you would surprise to think that new is not good for this method,
      #       but you should think that create delete flag to this
      def new
      end

      def create
        # TODO: Implement withdrawal logic
        redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.create.success")
      end
    end
  end
end
