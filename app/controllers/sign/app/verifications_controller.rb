# frozen_string_literal: true

module Sign
  module App
    class VerificationsController < Sign::App::Verification::BaseController
      def show
        if params[:scope].present? && params[:return_to].present?
          start_reauth_session!(scope: params[:scope], return_to_param: params[:return_to])
        end

        if current_reauth_session.present?
          return unless require_reauth_session!
        elsif verification_recent_for_get?(scope: @actor_token&.last_step_up_scope)
          flash.now[:notice] = I18n.t("sign.app.verification.success.complete")
        end

        @verification_scope = params[:scope].presence || current_reauth_scope
        @verification_return_to = params[:return_to].presence || current_reauth_return_to_param
        @available_methods = available_step_up_methods
        @reauth_sessions = ReauthSession.for_actor(@actor_token).recent_first.limit(50)
      rescue ActionController::BadRequest
        clear_reauth_state!
        redirect_to sign_app_configuration_path(ri: params[:ri]),
                    alert: I18n.t("auth.step_up.invalid_request", default: "不正なリクエストです")
      end
    end
  end
end
