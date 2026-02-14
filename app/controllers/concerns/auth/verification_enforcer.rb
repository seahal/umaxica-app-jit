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

      if request.get? || request.head?
        safe_return_to = safe_internal_path(request.fullpath.to_s).presence || "/"
        encoded_return_to = Base64.urlsafe_encode64(safe_return_to)

        safe_redirect_to(
          verification_redirect_path(return_to: encoded_return_to),
          fallback: verification_redirect_fallback,
          status: :found,
        )
      else
        render plain: REAUTH_REQUIRED_MESSAGE, status: :unauthorized
      end

      false
    end

    def verification_redirect_path(return_to:)
      attrs = { ri: params[:ri], return_to: return_to }
      scope = verification_scope.to_s.presence
      attrs[:scope] = scope if scope

      am_i_staff? ? sign_org_verification_path(attrs) : sign_app_verification_path(attrs)
    end

    def verification_redirect_fallback
      "/verification"
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
