# typed: false
# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Global
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include Pundit::Authorization
      # Note: RestrictedSessionGuard is still needed to enforce session expiration
      # and block expired restricted sessions on the session management page itself.
      include ::RestrictedSessionGuard
      # FIXME: in the future Current Support should be purge.
      include ::CurrentSupport
      include ::Finisher

      before_action :check_default_rate_limit

      allow_browser versions: :modern

      # NOTE: Order matters (dependencies rely on this sequence)
      # Layer order: RateLimit → Preference → AuthN(including AuthZ) → Verification → CurrentSupport

      before_action :check_default_rate_limit
      prepend_before_action :set_preferences_cookie
      # Restricted session guard - explicitly enabled to handle expired sessions
      # and prevent access to non-allowed routes for restricted sessions
      prepend_before_action :enforce_restricted_session_guard!
      prepend_before_action :resolve_param_context
      prepend_before_action :set_region
      prepend_before_action :set_locale
      prepend_before_action :set_timezone
      prepend_before_action :set_color_theme
      before_action :enforce_withdrawal_gate!
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      after_action :purge_current

      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: ENV.fetch(
                             "SIGN_APP_TRUSTED_ORIGINS",
                             "http://sign.app.localhost,https://sign.app.localhost",
                           )
                             .split(",").map(&:strip),
                           with: :exception

      guest_only!

      private

      # Redirect logged-in users from guest_only! pages to the configuration page.
      # Overrides Authentication::Base#after_login_path. ri is added automatically via default_url_options.
      def after_login_path
        sign_app_configuration_path
      rescue StandardError
        "/"
      end
    end
  end
end
