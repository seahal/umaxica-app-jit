# frozen_string_literal: true

Rails.application.config.to_prepare do
  if defined?(Sign::Org::VerificationsController) && defined?(Sign::Org::Verification::BaseController)
    Sign::Org::VerificationsController.class_eval do
      # Include necessary modules from BaseController
      include Common::Otp
      include ::Auth::StepUp
      include Sign::Webauthn
      include Sign::VerificationTiming

      # Constants from BaseController
      REAUTH_TTL = Sign::Org::Verification::BaseController::REAUTH_TTL
      REAUTH_SESSION_KEY = Sign::Org::Verification::BaseController::REAUTH_SESSION_KEY
      ALLOWED_SCOPES = Sign::Org::Verification::BaseController::ALLOWED_SCOPES

      # Override show to start reauth session if params are present
      def show
        if params[:scope].present? && params[:return_to].present?
          start_reauth_session!(scope: params[:scope], return_to_param: params[:return_to])
        end

        if current_reauth_session.present?
          return unless require_reauth_session!
        elsif verification_recent_for_get?(scope: @actor_token&.last_step_up_scope)
          flash.now[:notice] = I18n.t("sign.org.verification.success.complete")
        end

        @verification_scope = params[:scope].presence || (current_reauth_session && current_reauth_session["scope"])
        @verification_return_to = params[:return_to].presence || (current_reauth_session && current_reauth_session["return_to"] && Base64.urlsafe_encode64(current_reauth_session["return_to"]))
        @available_methods = available_step_up_methods
        @reauth_sessions = ReauthSession.for_actor(@actor_token).recent_first.limit(50)
      rescue ActionController::BadRequest
        session.delete(REAUTH_SESSION_KEY)
        redirect_to sign_org_configuration_path(ri: params[:ri]),
                    alert: I18n.t("auth.step_up.invalid_request", default: "不正なリクエストです")
      end

      private

      # Helper methods from BaseController
      def start_reauth_session!(scope:, return_to_param:)
        decoded = Base64.urlsafe_decode64(return_to_param.to_s)
        safe_path = safe_internal_path(decoded)
        raise ActionController::BadRequest, "invalid return_to" if safe_path.blank?

        scope_str = scope.to_s
        raise ActionController::BadRequest, "invalid scope" unless ALLOWED_SCOPES.key?(scope_str)

        pattern = ALLOWED_SCOPES[scope_str]
        raise ActionController::BadRequest, "scope mismatch" unless safe_path.match?(pattern)

        session[REAUTH_SESSION_KEY] = {
          "user_id" => current_staff.id,
          "scope" => scope_str,
          "return_to" => safe_path,
          "expires_at" => REAUTH_TTL.from_now.to_i,
        }
      rescue ArgumentError
        raise ActionController::BadRequest, "invalid return_to encoding"
      end

      def current_reauth_session
        session[REAUTH_SESSION_KEY]
      end

      def require_reauth_session!
        rs = current_reauth_session
        if rs.present? &&
            rs["expires_at"].to_i > Time.current.to_i &&
            rs["user_id"] == current_staff.id &&
            rs["scope"].present?
          return true
        end

        session.delete(REAUTH_SESSION_KEY)
        redirect_to sign_org_configuration_path(ri: params[:ri]),
                    alert: I18n.t("auth.step_up.session_expired", default: "再認証が必要です")
        false
      end
    end
  end
end
