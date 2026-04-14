# typed: false
# frozen_string_literal: true

module Sign
  module App
    module In
      class BulletinsController < Sign::App::ApplicationController
        auth_required!
        before_action :authenticate_user!
        before_action :maybe_inject_test_bulletin!
        before_action :require_bulletin_state
        before_action :guard_timeout, only: %i(show update)

        def show
          @bulletin = current_bulletin
        end

        def update
          refresh_bulletin_dimension!
          safe_redirect_to(
            sign_app_in_bulletin_path(rd: params[:rd], ri: params[:ri]),
            fallback: sign_app_in_bulletin_path(ri: params[:ri]),
          )
        end

        def destroy
          rd_param = params[:rd].presence
          consume_bulletin!
          safe_redirect_to_rd_or_default!(
            rd_param,
            default_path: sign_app_configuration_path(ri: params[:ri]),
          )
        end

        private

        def require_bulletin_state
          return if bulletin_state.present?

          render plain: I18n.t("sign.app.in.bulletins.forbidden"), status: :forbidden
        end

        def guard_timeout
          return unless bulletin_expired?

          render plain: I18n.t("sign.app.in.bulletins.timeout"), status: :request_timeout
        end
      end
    end
  end
end
