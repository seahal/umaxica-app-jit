# frozen_string_literal: true

class Sign::Org::VerificationController < Sign::Org::Verification::BaseController
  def show
    if params[:scope].present? && params[:return_to].present?
      start_reauth_session!(scope: params[:scope], return_to_param: params[:return_to])
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
                alert: I18n.t("auth.step_up.invalid_request", default: "不正なリクエストです")
  end
end
