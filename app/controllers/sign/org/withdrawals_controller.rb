module Sign
  module Org
    class WithdrawalsController < ApplicationController
      def new
      end

      def create
        # TODO: Implement withdrawal logic
        redirect_to sign_org_root_path, notice: t("sign.org.withdrawal.create.success")
      end
    end
  end
end
