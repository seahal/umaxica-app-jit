# frozen_string_literal: true

require "base64"

module Auth
  module VerificationEnforcer
    extend ActiveSupport::Concern

    REAUTH_REQUIRED_MESSAGE = "Re-authentication required"

    included do
      before_action :enforce_verification_if_required
    end

    def verification_required_action?
      false
    end

    def verification_scope
      nil
    end

    def verification_satisfied?
      actor_token = current_actor_token
      return false unless actor_token

      raw_token = cookies[verification_model.cookie_name].to_s
      return false if raw_token.blank?

      digest = verification_model.digest_token(raw_token)
      verification =
        verification_model
          .active
          .find_by(verification_token_foreign_key => actor_token.id, :token_digest => digest)

      return false unless verification

      begin
        # rubocop:disable Rails/SkipsModelValidations
        verification.update_column(:last_used_at, Time.current)
        # rubocop:enable Rails/SkipsModelValidations
      rescue ActiveRecord::ReadOnlyError
        # Skip update in readonly mode (e.g., during parallel tests)
      end
      true
    end

    private

    def enforce_verification_if_required
      return true if respond_to?(:logged_in?) && !logged_in?
      return true unless verification_required_action?
      return true if verification_satisfied?
      return false unless enforce_step_up_prereqs!

      if request.get? || request.head?
        safe_redirect_to(
          verification_redirect_path(rd: encoded_step_up_rd),
          fallback: verification_redirect_fallback,
          status: :found,
        )
      else
        render plain: REAUTH_REQUIRED_MESSAGE, status: :unauthorized
      end

      false
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
          configured_step_up_methods.empty? ? verification_setup_redirect_fallback :
                                                                 verification_redirect_fallback

        safe_redirect_to(destination, fallback: fallback, status: :found)
      else
        render plain: I18n.t("auth.step_up.register_methods_required"), status: :unprocessable_content
      end

      false
    end

    def verification_redirect_path(rd:, scope_override: nil)
      attrs = { ri: params[:ri], rd: rd }
      scope = scope_override.to_s.presence || verification_scope.to_s.presence
      attrs[:scope] = scope if scope

      am_i_staff? ? sign_org_verification_path(attrs) : sign_app_verification_path(attrs)
    end

    def verification_setup_redirect_path
      attrs = { ri: params[:ri], rd: encoded_step_up_rd }
      am_i_staff? ? new_sign_org_verification_setup_path(attrs) : new_sign_app_verification_setup_path(attrs)
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
      am_i_staff? ? %i(passkey totp) : %i(email_otp passkey totp)
    end

    def current_actor
      return current_staff if respond_to?(:am_i_staff?) && am_i_staff? && respond_to?(:current_staff)
      return current_user if respond_to?(:current_user)

      nil
    end

    def encoded_step_up_rd
      safe_path = safe_internal_path(request.fullpath.to_s).presence || "/"
      Base64.urlsafe_encode64(safe_path)
    end

    def current_actor_token
      return nil if current_session_public_id.blank?

      token_class.find_by(public_id: current_session_public_id, revoked_at: nil)
    end

    def verification_model
      am_i_staff? ? StaffVerification : UserVerification
    end

    def verification_token_foreign_key
      am_i_staff? ? :staff_token_id : :user_token_id
    end
  end
end
