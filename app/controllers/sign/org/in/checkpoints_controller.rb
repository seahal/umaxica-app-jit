# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module In
      class CheckpointsController < Sign::Org::ApplicationController
        auth_required!
        before_action :authenticate_staff!
        before_action :maybe_inject_test_checkpoint!
        before_action :require_checkpoint_state
        before_action :guard_timeout, only: %i(show update)

        def show
        end

        def update
          refresh_checkpoint_dimension!
          redirect_to sign_org_in_checkpoint_path(rd: params[:rd], ri: params[:ri])
        end

        def destroy
          rd_param = params[:rd].presence
          consume_checkpoint!
          safe_redirect_to_rd_or_default!(rd_param, default_path: sign_org_root_path(ri: params[:ri]))
        end

        private

        def require_checkpoint_state
          return if checkpoint_state.present?

          render plain: I18n.t("sign.org.in.checkpoints.forbidden"), status: :forbidden
        end

        def guard_timeout
          return unless checkpoint_expired?

          render plain: I18n.t("sign.org.in.checkpoints.timeout"), status: :request_timeout
        end
      end
    end
  end
end
