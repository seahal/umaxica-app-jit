# frozen_string_literal: true

# Manages session (refresh token) limits for Org staff.
# When a staff member exceeds their maximum concurrent sessions during login,
# they are redirected here to revoke existing sessions before proceeding.
#
# Routes:
#   GET  /in/passkeys/:passkey_id/sessions/edit -> #edit
#   PATCH /in/passkeys/:passkey_id/sessions     -> #update
#   GET  /in/secret/sessions/edit               -> #edit
#   PATCH /in/secret/sessions                   -> #update
class Sign::Org::In::SessionsController < ApplicationController
  include SessionLimitGate

  # The gate is required for both edit and update actions
  before_action :require_valid_gate

  # Display active sessions for the staff to select which to revoke
  def edit
    @pending_staff = load_pending_staff
    unless @pending_staff
      return redirect_to login_path,
                         alert: I18n.t("session_limit.staff_not_found", default: "スタッフが見つかりません。もう一度ログインしてください。")
    end

    @active_sessions = @pending_staff.staff_tokens.where(revoked_at: nil).order(created_at: :desc)
  end

  # Revoke selected sessions
  def update
    @pending_staff = load_pending_staff
    unless @pending_staff
      return redirect_to login_path,
                         alert: I18n.t("session_limit.staff_not_found", default: "スタッフが見つかりません。もう一度ログインしてください。")
    end

    revoke_ids = Array(params[:revoke_session_ids]).compact_blank

    if revoke_ids.empty?
      flash[:alert] = I18n.t("session_limit.no_sessions_selected", default: "無効化するセッションを選択してください。")
      @active_sessions = @pending_staff.staff_tokens.where(revoked_at: nil).order(created_at: :desc)
      return render :edit, status: :unprocessable_content
    end

    revoke_sessions_for_staff(@pending_staff, revoke_ids)
    consume_session_limit_gate!
    resolve_pending_sessions_for(@pending_staff)

    # Redirect back to the original login flow
    return_path = session_limit_return_to
    if return_path.present?
      redirect_to return_path, notice: I18n.t("session_limit.sessions_revoked", default: "セッションを無効化しました。ログインを続行してください。")
    else
      redirect_to login_path, notice: I18n.t("session_limit.sessions_revoked", default: "セッションを無効化しました。ログインを続行してください。")
    end
  end

  private

    def require_valid_gate
      require_session_limit_gate!(login_path: login_path)
    end

    def login_path
      new_sign_org_in_path
    end

    # Load the staff whose session we're managing.
    # The staff ID is stored in the session during the login flow.
    def load_pending_staff
      return session_limit_pending_staff if defined?(session_limit_pending_staff) && session_limit_pending_staff

      staff_id = session[:pending_login_staff_id]
      return nil unless staff_id

      Staff.find_by(id: staff_id)
    end

    # Revoke selected sessions in a transaction with row locking
    def revoke_sessions_for_staff(staff, session_ids)
      TokenRecord.connected_to(role: :writing) do
        StaffToken.transaction do
          # Lock the staff row to serialize concurrent operations
          staff.lock! if staff.respond_to?(:lock!)

          sessions_to_revoke = staff.staff_tokens
                                    .where(id: session_ids, revoked_at: nil)

          sessions_to_revoke.find_each do |token|
            token.update!(revoked_at: Time.current)
            # TODO: Add revoked_reason if column exists
            # token.update!(revoked_at: Time.current, revoked_reason: "concurrent_sessions_limit")
          end
        end
      end
    end

    def resolve_pending_sessions_for(resource)
      return unless session_limit_pending?

      remaining = count_active_sessions(resource)

      clear_pending_login_resource! if remaining <= max_sessions_for_resource(resource)
    end
end
