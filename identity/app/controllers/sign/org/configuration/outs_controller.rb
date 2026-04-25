# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Configuration
      class OutsController < ApplicationController
        include ::Verification::Staff

        auth_required!
        before_action :authenticate!

        def edit
        end

        def destroy
          Oidc::SingleLogoutService.call_for_staff(staff: current_staff) if current_staff
          log_out
          redirect_to(identity.sign_org_root_path, notice: t("sign.shared.sign_out.success"))
        end

        private
      end
    end
  end
end
