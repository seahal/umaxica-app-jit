# frozen_string_literal: true

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

    STEP_UP_TTL = 10.minutes

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

      flash[:alert] = I18n.t("auth.step_up.required")
      reauth_new_path = am_i_staff? ? :sign_org_verification_path : :sign_app_verification_path
      redirect_to send(
        reauth_new_path,
        scope: scope,
        return_to: generate_redirect_url(request.fullpath),
        ri: params[:ri],
      )
    end

    private

    def current_session_token
      return nil if current_session_public_id.blank?

      token_class.find_by(public_id: current_session_public_id)
    end
  end
end
