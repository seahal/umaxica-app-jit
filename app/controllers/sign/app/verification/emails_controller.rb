# frozen_string_literal: true

class Sign::App::Verification::EmailsController < Sign::App::Verification::BaseController
  def new
    return unless require_reauth_session!
    return if redirect_if_recent_verification_for_get!
    return unless require_method_available!(:email_otp)

    if email_otp_session_active?
      nonce = ensure_email_nonce!
      redirect_to edit_sign_app_verification_email_path(nonce, ri: params[:ri])
      return
    end

    unless send_email_otp!
      render :new, status: :unprocessable_content
      return
    end

    nonce = ensure_email_nonce!
    redirect_to edit_sign_app_verification_email_path(nonce, ri: params[:ri])
  end

  def edit
    return unless require_reauth_session!
    return if redirect_if_recent_verification_for_get!

    nil unless require_email_nonce!
  end

  def create
    return unless require_reauth_session!
    return if redirect_if_recent_verification_for_post!
    return unless require_method_available!(:email_otp)

    if email_otp_session_active?
      nonce = ensure_email_nonce!
      redirect_to edit_sign_app_verification_email_path(nonce, ri: params[:ri])
      return
    end

    unless send_email_otp!
      render :new, status: :unprocessable_content
      return
    end

    nonce = ensure_email_nonce!
    redirect_to edit_sign_app_verification_email_path(nonce, ri: params[:ri])
  end

  def update
    return unless require_reauth_session!
    return if redirect_if_recent_verification_for_post!
    return unless require_email_nonce!

    if verify_email_otp!
      consume_reauth_session!
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def require_email_nonce!
    rs = current_reauth_session
    if rs.present? && rs["email_nonce"].present? && params[:id] == rs["email_nonce"]
      return true
    end

    redirect_to sign_app_verification_path(ri: params[:ri]),
                alert: I18n.t("auth.step_up.invalid_request", default: "不正なリクエストです")
    false
  end
end
