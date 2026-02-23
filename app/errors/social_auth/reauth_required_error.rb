# typed: false
# frozen_string_literal: true

module SocialAuth
  # Raised when a sensitive operation requires recent re-authentication
  # but the user's last_reauth_at is too old or missing.
  # Maps to HTTP 403 Forbidden (not 401 to avoid triggering browser auth dialogs)
  class ReauthRequiredError < BaseError
    def initialize(i18n_key = "errors.social_auth.reauth_required", **context)
      super(i18n_key, :forbidden, **context)
    end
  end
end
