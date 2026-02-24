# typed: false
# frozen_string_literal: true

require "base64"

module Verification
  module Base
    extend ActiveSupport::Concern

    include Common::Redirect

    REAUTH_REQUIRED_MESSAGE = "Re-authentication required"
    STEP_UP_TTL = 15.minutes
    STEP_UP_REQUIRED_MESSAGE = "再認証が必要です\n操作は保存されていません"

    def verification_requirement
      @required_verification
    end

    def require_verification!(requirement)
      @required_verification = requirement.to_sym
    end

    def clear_verification_requirement!
      @required_verification = nil
    end

    def verification_required?
      verification_requirement.present? ||
        (respond_to?(:verification_required_action?, true) && verification_required_action?)
    end

    def verification_scope
      verification_requirement
    end

    def verification_satisfied?
      actor_token = current_actor_token
      return false unless actor_token

      raw_token = cookies[verification_model.cookie_name].to_s
      return false if raw_token.blank?

      digest = verification_model.digest_token(raw_token)
      verification = verification_model.active.find_by(
        verification_token_foreign_key => actor_token.id,
        :token_digest => digest,
      )

      return false unless verification

      begin
        verification.touch(:last_used_at)
      rescue ActiveRecord::ReadOnlyError
        nil
      end
      true
    end

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

      require_verification!(scope)
      return false unless enforce_step_up_prereqs!(scope_override: scope)

      flash[:alert] = I18n.t("auth.step_up.required")
      if request.get? || request.head?
        redirect_to actor_verification_path(
          scope: scope,
          rd: encoded_relative_return_to(request.fullpath),
          ri: params[:ri],
        )
        return false
      end

      if request.format.json?
        render json: { error: STEP_UP_REQUIRED_MESSAGE }, status: :unprocessable_content
      else
        render plain: STEP_UP_REQUIRED_MESSAGE, status: :unprocessable_content
      end
      false
    end

    private

    def enforce_verification_if_required
      return true if respond_to?(:logged_in?) && !logged_in?
      return true unless verification_required?
      return true if verification_satisfied?
      return false unless enforce_step_up_prereqs!(scope_override: verification_scope)

      handle_unverified_actor!
      false
    end

    def handle_unverified_actor!
      if request.get? || request.head?
        safe_redirect_to(
          verification_redirect_path(rd: encoded_step_up_rd),
          fallback: verification_redirect_fallback,
          status: :found,
        )
      elsif request.format.json?
        render json: { error: REAUTH_REQUIRED_MESSAGE }, status: :unauthorized
      else
        render plain: REAUTH_REQUIRED_MESSAGE, status: :unauthorized
      end
    end

    def enforce_step_up_prereqs!(scope_override: nil)
      return true if available_step_up_methods.present?

      if request.get? || request.head?
        destination =
          if configured_step_up_methods.empty?
            verification_setup_redirect_path
          else
            verification_redirect_path(rd: encoded_step_up_rd, scope_override: scope_override)
          end
        fallback =
          if configured_step_up_methods.empty?
            verification_setup_redirect_fallback
          else
            verification_redirect_fallback
          end

        safe_redirect_to(destination, fallback: fallback, status: :found)
      elsif request.format.json?
        render json: { error: I18n.t("auth.step_up.register_methods_required") }, status: :unprocessable_content
      else
        render plain: I18n.t("auth.step_up.register_methods_required"), status: :unprocessable_content
      end

      false
    end

    def actor_verification_path(attrs)
      actor_staff? ? sign_org_verification_path(attrs) : sign_app_verification_path(attrs)
    end

    def verification_redirect_path(rd:, scope_override: nil)
      attrs = { ri: params[:ri], rd: rd }
      scope = scope_override.to_s.presence || verification_scope.to_s.presence
      attrs[:scope] = scope if scope

      actor_verification_path(attrs)
    end

    def verification_setup_redirect_path
      attrs = { ri: params[:ri], rd: encoded_step_up_rd }
      actor_staff? ? new_sign_org_verification_setup_path(attrs) : new_sign_app_verification_setup_path(attrs)
    end

    def verification_redirect_fallback
      "/verification"
    end

    def verification_setup_redirect_fallback
      "/verification/setup"
    end

    def available_step_up_methods(actor = current_actor)
      ::StepUp::AvailableMethods.call(actor) & step_up_supported_methods
    end

    def configured_step_up_methods(actor = current_actor)
      ::StepUp::ConfiguredMethods.call(actor) & step_up_supported_methods
    end

    def step_up_supported_methods
      actor_staff? ? %i(passkey totp) : %i(email_otp passkey totp)
    end

    def current_actor
      return current_staff if actor_staff? && respond_to?(:current_staff)
      return current_user if respond_to?(:current_user)

      nil
    end

    def encoded_step_up_rd
      safe_path = safe_internal_path(request.fullpath.to_s).presence || "/"
      Base64.urlsafe_encode64(safe_path)
    end

    def encoded_relative_return_to(path)
      safe_path = safe_internal_path(path.to_s)
      Base64.urlsafe_encode64(safe_path.presence || "/")
    end

    def current_session_token
      return nil if current_session_public_id.blank?

      token_class.find_by(public_id: current_session_public_id)
    end

    def current_actor_token
      return nil if current_session_public_id.blank?

      token_class.find_by(public_id: current_session_public_id, revoked_at: nil)
    end

    def verification_model
      actor_staff? ? StaffVerification : UserVerification
    end

    def verification_token_foreign_key
      actor_staff? ? :staff_token_id : :user_token_id
    end

    def actor_staff?
      false
    end
  end
end
