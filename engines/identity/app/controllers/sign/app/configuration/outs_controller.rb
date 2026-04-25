# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module App
        module Configuration
          class OutsController < ApplicationController
            include ::Verification::User

            auth_required!
            before_action :authenticate!

            def edit
            end

            def destroy
              Oidc::SingleLogoutService.call(user: current_user) if current_user
              log_out
              redirect_to(identity.sign_app_root_path, notice: t("sign.shared.sign_out.success"))
            end

            private
          end
        end
      end
    end
  end
end
