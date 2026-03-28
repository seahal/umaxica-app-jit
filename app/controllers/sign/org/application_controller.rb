# typed: false
# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Global
      include ::Preference::Adoption
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff # TODO: i want to remove this.
      include Pundit::Authorization # TODO: i want to remove this.
      include ::RestrictedSessionGuard # TODO: i want to remove this.
      include ::CurrentSupport
      include ::Finisher

      before_action :check_default_rate_limit

      allow_browser versions: :modern

      # Restricted session guard - explicitly enabled to block restricted sessions
      # from accessing routes other than /in/session
      # NOTE: Order matters (dependencies rely on this sequence)
      # Layer order: RateLimit → Preference → AuthN(including AuthZ) → Verification → CurrentSupport
      prepend_before_action :set_preferences_cookie
      prepend_before_action :resolve_param_context
      prepend_before_action :set_region
      prepend_before_action :set_locale
      prepend_before_action :set_timezone
      prepend_before_action :set_color_theme
      before_action :enforce_restricted_session_guard!
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      after_action :purge_current

      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: ENV.fetch(
                             "SIGN_ORG_TRUSTED_ORIGINS",
                             "http://sign.org.localhost,https://sign.org.localhost",
                           )
                             .split(",").map(&:strip),
                           with: :exception

      guest_only!

      private

      # Redirect logged-in users from guest_only! pages to the configuration page.
      # Overrides Authentication::Base#after_login_path. ri is added automatically via default_url_options.
      def after_login_path
        sign_org_configuration_path
      rescue StandardError
        "/"
      end
    end
  end
end
