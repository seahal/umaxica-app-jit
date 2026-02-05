# frozen_string_literal: true

class Sign::App::Verification::EmailsController < Sign::App::Verification::BaseController
  def new
    @reauth_session = ReauthSession.new(
      scope: params[:scope].to_s,
      return_to: params[:return_to].to_s,
    )
  end

  def edit
    load_reauth_session!(params[:id])
    nil unless ensure_pending_and_not_expired!
  end

  def create
    build_reauth_session!(
      method: "email_otp",
      scope: verification_params[:scope],
      return_to: verification_params[:return_to],
    )
    prepare_method_side_effects!(@reauth_session)
    redirect_to edit_sign_app_verification_email_path(@reauth_session.id, ri: params[:ri])
  rescue ArgumentError
    @reauth_session ||= ReauthSession.new
    @reauth_session.errors.add(:return_to, :invalid)
    render :new, status: :unprocessable_content
  rescue ActiveRecord::RecordInvalid => e
    @reauth_session = e.record
    render :new, status: :unprocessable_content
  end

  def update
    load_reauth_session!(params[:id])
    return unless ensure_pending_and_not_expired!

    if verify_email_otp!
      verify_success!
    else
      @reauth_session.update!(attempt_count: @reauth_session.attempt_count + 1)
      render :edit, status: :unprocessable_content
    end
  end
end
