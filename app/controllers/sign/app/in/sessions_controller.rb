# frozen_string_literal: true

# Manages session (refresh token) limits for App users.
# When a user exceeds their maximum concurrent sessions during login,
# they are redirected here to revoke existing sessions before proceeding.
#
# Routes:
#   GET  /in/email/session/edit    -> #edit
#   PATCH /in/email/session        -> #update
#   GET  /in/secret/session/edit   -> #edit
#   PATCH /in/secret/session       -> #update
#   GET  /in/passkeys/:passkey_id/sessions/edit -> #edit
#   PATCH /in/passkeys/:passkey_id/sessions     -> #update
class Sign::App::In::SessionsController < ApplicationController
  include SessionLimitGate

  # The gate is required for both edit and update actions
  before_action :require_valid_gate

  # Display active sessions for the user to select which to revoke
  def edit
    @pending_user = load_pending_user
    unless @pending_user
      return redirect_to login_path,
                         alert: I18n.t("session_limit.user_not_found", default: "ユーザーが見つかりません。もう一度ログインしてください。")
    end

    @active_sessions = @pending_user.user_tokens.where(revoked_at: nil).order(created_at: :desc)
  end

  # Revoke selected sessions
  def update
    @pending_user = load_pending_user
    unless @pending_user
      return redirect_to login_path,
                         alert: I18n.t("session_limit.user_not_found", default: "ユーザーが見つかりません。もう一度ログインしてください。")
    end

    revoke_ids = Array(params[:revoke_session_ids]).compact_blank

    if revoke_ids.empty?
      flash[:alert] = I18n.t("session_limit.no_sessions_selected", default: "無効化するセッションを選択してください。")
      @active_sessions = @pending_user.user_tokens.where(revoked_at: nil).order(created_at: :desc)
      return render :edit, status: :unprocessable_content
    end

    revoke_sessions_for_user(@pending_user, revoke_ids)
    consume_session_limit_gate!
    resolve_pending_sessions_for(@pending_user)

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
      new_sign_app_in_path
    end

    # Load the user whose session we're managing.
    # The user ID is stored in the session during the login flow.
    def load_pending_user
      return session_limit_pending_user if defined?(session_limit_pending_user) && session_limit_pending_user

      user_id = session[:pending_login_user_id]
      return nil unless user_id

      User.find_by(id: user_id)
    end

    # Revoke selected sessions in a transaction with row locking
    def revoke_sessions_for_user(user, session_ids)
      TokenRecord.connected_to(role: :writing) do
        UserToken.transaction do
          # Lock the user row to serialize concurrent operations
          user.lock! if user.respond_to?(:lock!)

          sessions_to_revoke = user.user_tokens
                                   .where(id: session_ids, revoked_at: nil)

          sessions_to_revoke.find_each do |token|
            token.update!(revoked_at: Time.current)
            # TODO: Add revoked_reason if column exists
            # token.update!(revoked_at: Time.current, revoked_reason: "concurrent_sessions_limit")
          end

          def resolve_pending_sessions_for(user)
            return unless session_limit_pending?

            remaining = count_active_sessions(user)

            clear_pending_login_resource! if remaining <= max_sessions_for_resource(user)
          end
        end
      end
    end
end
