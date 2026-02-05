# frozen_string_literal: true

class Sign::Org::Verification::PasskeysController < Sign::Org::Verification::BaseController
  def new
    if params[:session_id].blank?
      redirect_to sign_org_verification_path(ri: params[:ri])
      return
    end

    load_reauth_session!(params[:session_id])
    return unless ensure_pending_and_not_expired!

    prepare_passkey_challenge!
  end

  def create
    if verification_params[:session_id].present?
      load_reauth_session!(verification_params[:session_id])
      return unless ensure_pending_and_not_expired!

      if verify_passkey!
        verify_success!
      else
        @reauth_session.update!(attempt_count: @reauth_session.attempt_count + 1)
        prepare_passkey_challenge!
        render :new, status: :unprocessable_content
      end

      return
    end

    build_reauth_session!(
      method: "passkey",
      scope: verification_params[:scope],
      return_to: verification_params[:return_to],
    )
    redirect_to new_sign_org_verification_passkey_path(session_id: @reauth_session.id, ri: params[:ri])
  rescue ArgumentError
    @reauth_session ||= ReauthSession.new
    @reauth_session.errors.add(:return_to, :invalid)
    render_verification_show
  rescue ActiveRecord::RecordInvalid => e
    @reauth_session = e.record
    render_verification_show
  end
end
