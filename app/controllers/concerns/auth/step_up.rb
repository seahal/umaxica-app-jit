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

    STEP_UP_TTL = 15.minutes
    STEP_UP_REQUIRED_MESSAGE = "再認証が必要です\n操作は保存されていません"
    INITIAL_SETUP_CONTROLLERS = {
      "sign/app/configuration/totps" => {
        get_actions: %w(index new),
        non_get_actions: %w(create),
      },
      "sign/app/configuration/passkeys" => {
        get_actions: %w(index new),
        non_get_actions: %w(create options verification),
      },
      "sign/app/configuration/emails" => {
        get_actions: %w(index),
        non_get_actions: [],
      },
      "sign/app/configuration/emails/registrations" => {
        get_actions: %w(new edit),
        non_get_actions: %w(create update),
      },
      "sign/app/configuration/telephones/registrations" => {
        get_actions: %w(new edit),
        non_get_actions: %w(create update),
      },
    }.freeze

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
      return if initial_setup_step_up_exempt?

      flash[:alert] = I18n.t("auth.step_up.required")
      if request.get?
        reauth_new_path = am_i_staff? ? :sign_org_verification_path : :sign_app_verification_path
        redirect_to send(
          reauth_new_path,
          scope: scope,
          return_to: encoded_relative_return_to(request.fullpath),
          ri: params[:ri],
        )
        return false
      end

      render plain: STEP_UP_REQUIRED_MESSAGE, status: :unprocessable_content
      false
    end

    private

    def initial_setup_step_up_exempt?
      return false if current_actor.blank?
      return false if has_step_up_method?(current_actor)

      rules = INITIAL_SETUP_CONTROLLERS[controller_path]
      return false unless rules

      if request.get?
        rules[:get_actions].include?(action_name)
      else
        rules[:non_get_actions].include?(action_name)
      end
    end

    def has_step_up_method?(actor)
      return false unless actor

      if actor.respond_to?(:user_emails)
        return true if actor.user_emails.exists?(user_email_status_id: AuthMethodGuard::VERIFIED_EMAIL_STATUSES)
      end
      if actor.respond_to?(:user_passkeys)
        return true if actor.user_passkeys.active.exists?
      end
      if actor.respond_to?(:user_one_time_passwords)
        return true if actor.user_one_time_passwords.exists?(user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE)
      end

      if actor.respond_to?(:staff_emails)
        return true if actor.staff_emails.exists?(staff_identity_email_status_id: StaffEmailStatus::VERIFIED)
      end
      if actor.respond_to?(:staff_passkeys)
        return true if actor.staff_passkeys.active.exists?
      end
      if actor.respond_to?(:staff_one_time_passwords)
        return true if actor.staff_one_time_passwords.exists?(staff_one_time_password_status_id: StaffOneTimePasswordStatus::ACTIVE)
      end

      false
    end

    def current_actor
      return current_staff if respond_to?(:am_i_staff?) && am_i_staff? && respond_to?(:current_staff)
      return current_user if respond_to?(:current_user)

      nil
    end

    def available_step_up_methods(actor = current_actor)
      methods = []
      return methods unless actor

      if actor.respond_to?(:user_emails) &&
          actor.user_emails.exists?(user_email_status_id: UserEmailStatus::VERIFIED)
        methods << :email_otp
      end
      methods << :passkey if actor.respond_to?(:user_passkeys) && actor.user_passkeys.active.exists?
      if actor.respond_to?(:user_one_time_passwords) &&
          actor.user_one_time_passwords.exists?(user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE)
        methods << :totp
      end

      if actor.respond_to?(:staff_passkeys) && actor.staff_passkeys.active.exists?
        methods << :passkey
      end
      if actor.respond_to?(:staff_one_time_passwords) &&
          actor.staff_one_time_passwords.exists?(staff_one_time_password_status_id: StaffOneTimePasswordStatus::ACTIVE)
        methods << :totp
      end

      methods.uniq
    end

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
