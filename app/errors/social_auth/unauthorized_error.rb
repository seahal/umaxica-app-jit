# typed: false
# frozen_string_literal: true

module SocialAuth
  # Raised when social auth state/intent validation fails
  # - State mismatch
  # - Intent expired
  # - Missing required session data
  # Maps to HTTP 401 Unauthorized
  class UnauthorizedError < BaseError
    def initialize(i18n_key = "errors.social_auth.unauthorized", **context)
      super(i18n_key, :unauthorized, **context)
    end
  end
end
