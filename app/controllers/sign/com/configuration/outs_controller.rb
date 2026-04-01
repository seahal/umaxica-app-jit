# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class OutsController < ApplicationController
        include ::Verification::User

        auth_required!
        before_action :authenticate!

        def edit
        end

        def destroy
          Oidc::SingleLogoutService.call(user: current_customer) if current_customer
          log_out
          redirect_to(sign_com_root_path, notice: t("sign.shared.sign_out.success"))
        end
      end
    end
  end
end
