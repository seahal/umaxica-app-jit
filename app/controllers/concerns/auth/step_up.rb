# frozen_string_literal: true

require "base64"

module Auth
  # Controller concern for Step-Up Authentication (re-authentication gate).
  #
  # Requires recent re-authentication before sensitive operations.
  # State is stored per-session on the token record (UserToken / StaffToken).
  #
  # Usage:
  #   include Auth::StepUp
  #   before_action -> { require_step_up!(scope: "configuration_email") }
  module StepUp
    extend ActiveSupport::Concern
    include Auth::VerificationEnforcer

    STEP_UP_TTL = 15.minutes
    STEP_UP_REQUIRED_MESSAGE = "再認証が必要です\n操作は保存されていません"

    def step_up_satisfied?(scope:)
      token = current_session_token
      return false unless token

      return true if token.created_at >= STEP_UP_TTL.ago

      token.last_step_up_at.present? &&
        token.last_step_up_at > STEP_UP_TTL.ago &&
        token.last_step_up_scope == scope
    end

    def require_step_up!(scope:)
      return if step_up_satisfied?(scope: scope)
      return false unless enforce_step_up_prereqs!(scope_override: scope)

      flash[:alert] = I18n.t("auth.step_up.required")
      if request.get? || request.head?
        verification_path = am_i_staff? ? :sign_org_verification_path : :sign_app_verification_path
        redirect_to send(
          verification_path,
          scope: scope,
          rd: encoded_relative_return_to(request.fullpath),
          ri: params[:ri],
        )
        return false
      end

      render plain: STEP_UP_REQUIRED_MESSAGE, status: :unprocessable_content
      false
    end

    private

    def encoded_relative_return_to(path)
      safe_path = safe_internal_path(path.to_s)
      Base64.urlsafe_encode64(safe_path.presence || "/")
    end

    def current_session_token
      return nil if current_session_public_id.blank?

      token_class.find_by(public_id: current_session_public_id)
    end
  end
end
