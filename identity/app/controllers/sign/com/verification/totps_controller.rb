# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Verification
      class TotpsController < Sign::Com::ApplicationController
        auth_required!

        before_action :authenticate_customer!

        def new
          redirect_to(
            identity.sign_com_verification_path(ri: params[:ri]),
            alert: I18n.t("auth.step_up.method_unavailable"),
            status: :see_other,
          )
        end

        def create
          redirect_to(
            identity.sign_com_verification_path(ri: params[:ri]),
            alert: I18n.t("auth.step_up.method_unavailable"),
            status: :see_other,
          )
        end
      end
    end
  end
end
