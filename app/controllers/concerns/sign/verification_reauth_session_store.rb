# typed: false
# frozen_string_literal: true

module Sign
  module VerificationReauthSessionStore
    extend ActiveSupport::Concern

    private

    def start_reauth_session!(scope:, return_to_param:)
      decoded = Base64.urlsafe_decode64(return_to_param.to_s)
      safe_path = safe_internal_path(decoded)
      raise ActionController::BadRequest, "invalid return_to" if safe_path.blank?

      scope_str = scope.to_s
      raise ActionController::BadRequest, "invalid scope" unless self.class::ALLOWED_SCOPES.key?(scope_str)

      pattern = self.class::ALLOWED_SCOPES[scope_str]
      raise ActionController::BadRequest, "scope mismatch" unless safe_path.match?(pattern)

      session[self.class::REAUTH_SESSION_KEY] = {
        "user_id" => reauth_actor_id,
        "scope" => scope_str,
        "return_to" => safe_path,
        "expires_at" => self.class::REAUTH_TTL.from_now.to_i,
      }
    rescue ArgumentError
      raise ActionController::BadRequest, "invalid return_to encoding"
    end

    def current_reauth_session
      session[self.class::REAUTH_SESSION_KEY]
    end

    def reauth_actor_id
      raise NotImplementedError, "#{self.class} must define #reauth_actor_id"
    end
  end
end
