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
          log_out
          redirect_to sign_org_root_path, notice: t("sign.shared.sign_out.success")
        end

        private

        def verification_required_action?
          action_name == "destroy"
        end

        def verification_scope
          "withdrawal"
        end
      end
    end
  end
end
