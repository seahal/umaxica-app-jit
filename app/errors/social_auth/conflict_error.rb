# typed: false
# frozen_string_literal: true

module SocialAuth
  # Raised when there's a conflict in social auth operations
  # - Provider+UID already linked to another user
  # - Trying to unlink the last authentication method
  # Maps to HTTP 409 Conflict
  class ConflictError < BaseError
    def initialize(i18n_key = "errors.social_auth.conflict", **context)
      super(i18n_key, :conflict, **context)
    end
  end
end
