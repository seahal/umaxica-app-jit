# frozen_string_literal: true

class Sign::Org::VerificationController < Sign::Org::Verification::BaseController
  def show
    return_to_param = params[:return_to].presence || params[:rd].presence

    if params[:scope].present? && return_to_param.present?
      start_reauth_session!(scope: params[:scope], return_to_param: return_to_param)
    end

    if current_reauth_session.present?
      return unless require_reauth_session!
    elsif verification_recent_for_get?(scope: @actor_token&.last_step_up_scope)
      flash.now[:notice] = I18n.t("sign.org.verification.success.complete")
    end

    @available_methods = available_step_up_methods
  rescue ActionController::BadRequest
    session.delete(REAUTH_SESSION_KEY)
    redirect_to sign_org_configuration_path(ri: params[:ri]),
                alert: I18n.t("auth.step_up.invalid_request")
  end
end
